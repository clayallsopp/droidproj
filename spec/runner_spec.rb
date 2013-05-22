require 'spec_helper'

describe DroidProj::Runner do
  BASIC_DROIDFILE = %Q{
magic
block_magic do
  3
end}

  WORKING_DROIDFILE = %Q{
res do
  drawable 'back_icon' do
    hdpi './images/back@hdpi.png'
    ldpi './images/back@ldpi.png'
    mdpi './images/back.png'
  end
end}

  TEST_FOLDER = File.join(File.dirname(__FILE__), 'runnable_spec')

  before do
    FileUtils.mkdir TEST_FOLDER
    FileUtils.cp_r SPEC_RESOURCES, File.join(TEST_FOLDER, 'images')

    droidfile = File.join(TEST_FOLDER, 'Droidfile')
    File.open(droidfile, 'w') { |f| f.write(WORKING_DROIDFILE) }

    @runner = DroidProj::Runner.new
  end

  after do
    FileUtils.rm_rf TEST_FOLDER
  end

  describe "#eval_droidfile" do
    before do
      @temp_droidfile = File.join(File.dirname(__FILE__), '_droidfile')
      File.open(@temp_droidfile, 'w') { |file|
        file.write(BASIC_DROIDFILE)
      }
    end

    after do
      FileUtils.rm_f @temp_droidfile
    end

    it "should call methods of Android::App" do
      @runner.droidfile = @temp_droidfile
      @runner.app = Object.new.tap do |o|
        def o.magic
          @magic = true
        end

        def o.block_magic(&block)
          @block_magic = block.call
        end
      end

      @runner.eval_droidfile

      @runner.app.instance_variable_get("@magic").should == true
      @runner.app.instance_variable_get("@block_magic").should == 3
    end
  end

  describe ".run" do
    before do
     @original_dir = Dir.pwd
     Dir.chdir(TEST_FOLDER)
    DroidProj::Logger.logger.enabled = true
    end

    after do
      Dir.chdir @original_dir
      DroidProj::Logger.logger.enabled = false
    end

    it "should create the correct filesystem" do
      DroidProj::Runner.run

      ['drawable', 'drawable-hdpi', 'drawable-ldpi', 'drawable-mdpi'].each do |folder|
        Dir.exists?(File.join(TEST_FOLDER, 'res', folder)).should == true
        if folder != 'drawable'
          File.exists?(File.join(TEST_FOLDER, 'res', folder, 'back_icon.png')).should == true
        else
          File.exists?(File.join(TEST_FOLDER, 'res', folder, 'back_icon.xml')).should == true
        end
      end
    end
  end
end