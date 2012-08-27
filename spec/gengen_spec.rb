require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe GenGen do
  describe ".extract_otpions" do
    it "works" do
      args = ['foo/bar', 'bar', 'a=b', 'c=d']
      options = GenGen.extract_otpions!(args)
      args.should eq(['foo/bar', 'bar'])
      options.should eq({'a' => 'b', 'c' => 'd'})
    end
  end

  describe ".process" do
    let(:tmpdir) { File.join(Dir.mktmpdir, 'example') }

    before do
      FileUtils.cp_r(File.expand_path('../fixtures/example', __FILE__), tmpdir)
    end

    after do
      FileUtils.rm_rf(tmpdir)
    end

    it "works" do
      mock(STDIN).gets { "BAZ\n" }

      GenGen.process(tmpdir, 'var1' => 'FOO', 'var2' => 'BAR')

      File.read(File.join(tmpdir, 'foo.rb')).should eq("fooFOOfooBARbar\n")
      File.read(File.join(tmpdir, 'lib', 'bar.txt')).should eq("foo{{var1\n}}\nfooBARbar\n")
      File.read(File.join(tmpdir, 'BAR_xxx.rb')).should eq("fooBAZbar\n")
    end
  end
end
