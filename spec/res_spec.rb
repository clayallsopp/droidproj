require 'spec_helper'

describe DroidProj::Android::Resources do
  before do
    @res = DroidProj::Android::Resources.new
  end

  describe "#drawable" do
    describe "with instance_eval" do
      it "should create a new Drawable" do
        @drawable = @res.drawable 'my_image' do
          hdpi 'some_file.png', state_enabled: false
        end
      end
    end

    describe "with one argument" do
      it "should create a new Drawable" do
        @drawable = @res.drawable 'my_image' do |drawable|
          drawable.hdpi 'some_file.png', state_enabled: false
        end
      end
    end

    after do
      @drawable = @res['my_image']
      drawable_state = @drawable.states[{enabled: false}][0]
      drawable_state.file_path.should == "some_file.png"
      drawable_state.state[:enabled].should == false
      drawable_state.size.should == :hdpi
      @drawable = nil
    end
  end

  describe "#[]" do
    it "should return the correct drawable" do
      drawable = DroidProj::Android::Drawable.new
      drawable.name = "this is some random name"
      @res.drawables << drawable
      @res[drawable.name].should == drawable
    end
  end

  describe "#filesystem_hash" do
    it "should return the correct structure" do
      drawable = @res.drawable 'my_image' do
        state(enabled: false) do
          hdpi 'some_file_disabled@hdpi.png'
        end
        hdpi 'some_file@hdpi.png'
        ldpi 'some_file@ldpi.png'
      end

      write_op = DroidProj::Android::Resources::WriteOp.new
      write_op.at = "my_image.xml"
      write_op.content = drawable.xml_string

      hdpi_op = DroidProj::Android::Resources::MoveOp.new
      hdpi_op.from = 'some_file@hdpi.png'
      hdpi_op.to = "#{DroidProj::Android::Drawable::FINAL_FILE_PREFIX}my_image.png"

      hdpi_dis_op = DroidProj::Android::Resources::MoveOp.new
      hdpi_dis_op.from = 'some_file_disabled@hdpi.png'
      hdpi_dis_op.to = "#{DroidProj::Android::Drawable::FINAL_FILE_PREFIX}my_image_enabled_false.png"

      ldpi_op = DroidProj::Android::Resources::MoveOp.new
      ldpi_op.from = 'some_file@ldpi.png'
      ldpi_op.to = "#{DroidProj::Android::Drawable::FINAL_FILE_PREFIX}my_image.png"

      filesystem_hash = @res.filesystem_hash

      filesystem_hash[:drawable].should == [write_op]
      filesystem_hash["drawable-hdpi".to_sym].should == [hdpi_dis_op, hdpi_op]
      filesystem_hash["drawable-ldpi".to_sym].should == [ldpi_op]
    end
  end
end