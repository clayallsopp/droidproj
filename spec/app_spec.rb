require 'spec_helper'

describe DroidProj::Android::App do
  TEST_FOLDER = File.join(File.dirname(__FILE__), 'test_app')

  before do
    FileUtils.mkdir TEST_FOLDER

    @app = DroidProj::Android::App.new TEST_FOLDER
  end

  after do
    FileUtils.rm_rf TEST_FOLDER
  end


  describe "#res" do
    describe "with instance_eval" do
      it "should create a new Resources" do
        @res = @app.res do
          drawable 'my_image' do
          end
        end
      end
    end

    describe "with one argument" do
      it "should create a new Drawable" do
        @res = @app.res do |res|
          res.drawable 'my_image' do
          end
        end
      end
    end

    after do
      @res.should_not == nil
      @res.drawables.count.should == 1
      @res = nil
    end
  end

  describe "#create_filesystem!" do
    before do
      @app.res do
        drawable 'my_image' do
        end
      end

      @app.create_filesystem!
    end

    it "should create a res folder if it doesn't exist" do
      Dir.exists?(File.join(TEST_FOLDER, 'res')).should == true
    end

    it "should create a my_image xml file" do
      file = File.join(TEST_FOLDER, 'res', 'drawable', 'my_image.xml')
      File.exists?(file).should == true
    end
  end
end