module DroidProj
  module Android
    class ResourcesDrawables < Array
      def [](index_or_key)
        if index_or_key.is_a?(Numeric)
          super
        else
          self.select { |drawable|
            drawable.name == index_or_key
          }.first
        end
      end
    end

    class Resources
      class MoveOp
        attr_accessor :to, :from

        def ==(other)
          other.to == self.to && other.from == self.from
        end
      end

      class WriteOp
        attr_accessor :at, :content

        def ==(other)
          other.at == self.at && other.content == self.content
        end
      end

      attr_accessor :app
      attr_accessor :drawables

      def initialize
        @drawables = ResourcesDrawables.new
      end

      # Public: DSL for creating new drawables in the resources
      #
      # name - The String name of the drawable; *this* is what will be referred to
      #  in your Java code
      # &block - A DSL block where you can setup aspects of the drawable
      #
      # Examples
      #
      #   res.drawable 'my_image' do
      #     hdpi 'some_file.png', state_enabled: false
      #   end
      #   # => #<Android::Drawable>
      #   res.drawable 'my_image' do |drawable|
      #     drawable.hdpi 'some_file.png', state_enabled: false
      #   end
      #   # => #<Android::Drawable>
      #
      # Returns the new Android::Drawable instance
      def drawable(name, &block)
        drawable = DroidProj::Android::Drawable.new
        drawable.name = name
        @drawables << drawable

        case block.arity
        when 0
          drawable.instance_eval &block
        when 1
          block.call(drawable)
        end
        drawable
      end

      def [](key)
        self.drawables[key]
      end

      # Public: A Hash representing how the resources should be created in the
      #  filesytem
      #
      # Examples
      #
      #   res.filesystem_hash
      #   # => {drawable: ["drawable.xml"], drawable-hdpi: ["drawable.png"]}
      #
      # Returns the Hash
      def filesystem_hash
        hash = {
          drawable: []
        }
        self.drawables.each do |drawable|
          write_op = WriteOp.new
          write_op.at = drawable.name + ".xml"
          write_op.content = drawable.xml_string
          hash[:drawable] << write_op

          drawable.to_size_buckets.each do |size, drawable_states|
            drawable_states.each do |drawable_state|
              folder = (hash["drawable-#{size}".to_sym] ||= [])
              op = MoveOp.new
              op.from = drawable_state.file_path
              op.to = drawable_state.final_file_name
              folder << op
            end
          end
        end

        hash
      end
    end
  end
end