require 'pathname'

module DroidProj
  module Android
    class DrawableState
      # Hash of options which define what android:state this is for
      attr_accessor :state
      # Symbol for what size folder this goes into
      attr_accessor :size
      # String original path of the image file
      attr_accessor :file_path
      # Android::Drawable instance this state is for
      attr_accessor :drawable

      def initialize
        @state = {}
      end

      def xml_string
        str = "<item "
        self.state.each do |state, value|
          str << "android:state_#{state}=\"#{value}\" "
        end

        str << "android:drawable=\"@drawable/#{final_drawable_name}\" />"
      end

      def final_file_name
        final_drawable_name + "." + final_extension
      end

      def final_drawable_name
        final_file_name = ""
        final_file_name << self.drawable.name
        self.state.each do |state, value|
          final_file_name << "_#{state}_#{value}"
        end
        final_file_name
      end

      def final_extension
        file_name = Pathname.new(self.file_path).basename
        file_name.to_s.split('.')[1..-1].join('.')
      end
    end
  end
end