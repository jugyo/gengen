# encoding: utf-8
require "gengen/version"
require "tmpdir"
require "fileutils"

module GenGen
  REGEXP = /{{{\s*(.*?)\s*}}}/

  class << self
    def gen(args)
      args = args.dup
      options = extract_otpions!(args)
      puts "options: #{options.inspect}"

      github_project = args[0]
      unless github_project && github_project =~ /^\w+\/\w+$/
        abort "Usage: gengen user/template dirctory [foo=bar ...]"
      end

      temp_dir = fetch_from_github(github_project)
      process(temp_dir, options)

      dest_dir = args[1] || github_project.split('/')[1]
      FileUtils.mv(temp_dir, dest_dir)
    end

    def extract_otpions!(args)
      options = {}
      args.delete_if do |_|
        if _ =~ /^(\w+)=(\w+)$/
          options[$1] = $2
          true
        end
      end
      options
    end

    def fetch_from_github(github_project)
      temp_dir = Dir.mktmpdir
      git_url = "git@github.com:#{github_project}.git"
      system 'git', 'clone', git_url, temp_dir
      FileUtils.rm_rf(File.join(temp_dir, '.git'))
      temp_dir
    end

    def process(dir, vars)
      Dir[File.join(dir, '**', '*')].each do |filepath|
        next unless File.file?(filepath)

        basename = File.basename(filepath)
        if basename =~ REGEXP
          old_path = filepath
          new_path = File.join File.dirname(filepath), replace(basename, vars)
          puts "renaming... #{old_path.sub(dir + '/', '')} => #{new_path.sub(dir + '/', '')}"
          FileUtils.mv(old_path, new_path)
        end
      end

      Dir[File.join(dir, '**', '*')].each do |filepath|
        next unless File.file?(filepath)

        puts "processing... #{filepath.sub(dir + '/', '')}"
        contents = replace(File.read(filepath), vars)
        File.open(filepath, 'w') do |file|
          file.write contents
        end
      end

      puts 'done!'
    end

    def replace(text, vars)
      text.gsub(REGEXP) do |_|
        var_name = $1
        unless vars.key?(var_name)
          print "[#{var_name}]: "
          value = gets.strip
          vars[var_name] = value
        end
        vars[var_name]
      end
    end
  end
end
