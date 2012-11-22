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

      local = true if args.delete('-l') || args.delete('--local')

      if local
        git_url = args[0]
      else
        github_project = args[0]
        unless github_project && github_project =~ /^[^\/]+\/[^\/]+$/
          usage!
        end
        github_project += '.gengen' unless github_project =~ /\.gengen$/
        git_url = "https://github.com/#{github_project}.git"
      end

      dest_dir = if args[1]
          args[1]
        else
          print "[directory]: "
          STDIN.gets.strip
        end

      if File.exists?(dest_dir)
        abort "[error] '#{dest_dir}' already exists"
      end

      temp_dir = fetch(git_url)
      process(temp_dir, options)

      FileUtils.mv(temp_dir, dest_dir)
    end

    def usage!
      abort <<-D
Usage:
  gengen user/template [directory] [foo=bar ...]
  gengen --local(-l) git_repository_path [directory] [foo=bar ...]

Examples:
  gengen jugyo/sublime-plugin RubyUtils name=RubyUtils command=test
  gengen -l /path/to/sublime-plugin RubyUtils name=RubyUtils command=test
      D
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

    def fetch(git_url)
      temp_dir = Dir.mktmpdir
      puts "git clone #{git_url} ..."
      if system 'git', 'clone', git_url, temp_dir
        FileUtils.rm_rf(File.join(temp_dir, '.git'))
        temp_dir
      else
        abort "[error] faild to git clone '#{git_url}'!"
      end
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
          value = STDIN.gets.strip
          vars[var_name] = value.empty? ? var_name : value
        end
        vars[var_name]
      end
    end
  end
end
