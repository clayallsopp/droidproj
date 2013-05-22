module DroidProj
  module Android
    class Drawable
      # Hash of STATE_HASH =>
      attr_accessor :states
      # The final name for this drawable, used in your code
      attr_accessor :name
      # The current state being set for this drawable
      attr_accessor :active_state

      SIZES = [:hdpi, :ldpi, :mdpi, :xhdpi]
      attr_accessor *SIZES

      def initialize
        @active_state = {}
        @states = {}
      end

      # Public: The DSL for creating drawables corresponding to a certain state
      #
      # active_state - The Hash of options to set the `active_state`
      # &block - A block to be execute with the new `active_state`
      #
      # Examples
      #
      #   drawable.state(enabled: true, focused: false) do
      #     # In this block, all drawables are set with the above state
      #     hdpi 'image.png'
      #   end
      #
      # Returns the Drawable instance being used
      def state(active_state, &block)
        self.active_state = Hash[active_state.map {|k, v| [k.to_sym, v] }]
        block.call
        self.active_state = {}
        self
      end

      # Public: The DSL for creating & setting Anroid::DrawableState objects
      #
      # file_path = nil - The String path where the image file is located
      #
      # Examples
      #
      #   self.hdpi
      #   # => #<Android::Drawable::State> # the current drawable state
      #   self.hdpi "some_file.png"
      #   # => #<Android::Drawable::State> # a new drawable state, setting self.hdpi
      #
      # Returns the new Android::Drawable::State
      SIZES.each do |size|
        define_method(size, ->(file_path = nil, options = {}) {
          size_list = self.instance_variable_get("@#{size}")
          # EX self.hdpi
          # => #<Android::Drawable::State>
          if !file_path
            return size_list
          end

          # EX self.hdpi "some_file.png"
          drawable_state = DroidProj::Android::DrawableState.new
          drawable_state.drawable = self
          drawable_state.file_path = file_path
          drawable_state.size = size.to_sym
          temp_state = {}
          temp_state.merge!(self.active_state)
          options.merge(self.active_state).each do |key, value|
            if key.to_s.start_with?("state_")
              key_state = key.to_s.split("state_")[-1].to_sym
              temp_state[key_state] = value
            end
          end
          drawable_state.state = temp_state
          self.states[temp_state] ||= []
          self.states[temp_state] << drawable_state
          drawable_state
        })
      end

      def to_size_buckets
        size_buckets = {}
        self.states.each do |state, drawable_states|
          drawable_states.each do |drawable_state|
            size_buckets[drawable_state.size] ||= []
            size_buckets[drawable_state.size] << drawable_state
          end
        end
        size_buckets
      end

      # Public: The StateList XML representation of this drawable, used by Android
      #
      # Returns the String representation
      def xml_string
        str = %Q{
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
}

        self.sorted_states.each do |state, drawable_states|
          drawable_states.each do |drawable_state|
            if !str.include?(drawable_state.xml_string)
              str <<
%Q{    #{drawable_state.xml_string}
}
            end
          end
        end

        default_drawable = "<item android:drawable=\"@drawable/#{self.name}\" />\n"
        if !str.include?(default_drawable)
          str <<
%Q{    #{default_drawable}}
        end

            str <<
%Q{</selector>}
      end

      # Internal: Sort `self.states` by how long each state is
      #  (because Android wants the XML file to be sorted by specificity)
      #
      # Returns an Array relating to `self.states` as [:key, :value], sorted
      # by :key length
      def sorted_states
        keys = self.states.keys
        keys.sort_by! {|x|
          x.to_s.length
        }.reverse!
        sorted_hash = keys.map {|key|
          [key, self.states[key]]
        }
        sorted_hash
      end
    end
  end
end