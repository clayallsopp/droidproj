require 'spec_helper'

describe DroidProj::Android::Drawable do
  before do
    @drawable = DroidProj::Android::Drawable.new
    @drawable.name = "drawable_name"
  end

  describe DroidProj::Android::Drawable::SIZES, "DSL" do
    it "returns existing values" do
      @drawable.hdpi = "something"
      @drawable.hdpi.should == "something"
    end

    it "sets new values with the DSL" do
      drawable_state = @drawable.hdpi "some_file.png", state_enabled: true
      drawable_state.class.should == DroidProj::Android::DrawableState
      drawable_state.file_path.should == "some_file.png"
      drawable_state.state.should == {enabled: true}
    end
  end

  describe "#xml_string" do
    it "should produce the correct XML with basic options" do
      @drawable.hdpi "some_file.png", state_enabled: true

      @drawable.xml_string.should ==
%Q{<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_enabled="true" android:drawable="@drawable/drawable_name_enabled_true" />
    <item android:drawable="@drawable/drawable_name" />
</selector>}
    end

    it "should produce the correct XML with multiple files" do
      @drawable.hdpi "some_file.png"
      @drawable.hdpi "some_file.png", state_enabled: true
      @drawable.ldpi "some_file@ldpi.png", state_enabled: true

      @drawable.xml_string.should ==
%Q{<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_enabled="true" android:drawable="@drawable/drawable_name_enabled_true" />
    <item android:drawable="@drawable/drawable_name" />
</selector>}
    end
  end
end