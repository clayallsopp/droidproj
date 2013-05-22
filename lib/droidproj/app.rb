require 'fileutils'
require 'ap'

module DroidProj
  module Android
    class App
      attr_accessor :root_dir, :res_path, :res

      def initialize(root_dir)
        @root_dir = root_dir
      end

      def res_path
        @res_path || File.join(self.root_dir, 'res')
      end

      # Public: DSL for setting the app's resources
      #
      # &block  - (optional) Block which is called to create a new Android::Resources
      #  object, which is then set to self.res
      #
      # Returns either the existing Android::Resources object or the newly
      #  created one.
      def res(&block)
        if block
          @res ||= DroidProj::Android::Resources.new
          @res.app = self
          case block.arity
          when 0
            @res.instance_eval &block
          when 1
            block.call(@res)
          end
        end

        @res
      end

      # Public: Creates the necessary filesystem considering all options
      #
      def create_filesystem!
        return if !self.res

        res_filesystem = self.res.filesystem_hash

        DroidProj::Logger.log "Creating #{res_path}..."
        FileUtils.mkdir_p res_path

        res_filesystem.each do |folder, files|
          folder = folder.to_s
          folder_path = File.join(res_path, folder)
          DroidProj::Logger.log "Creating #{folder_path}...".green
          FileUtils.mkdir_p folder_path
          files.each do |file_op|
            case file_op
            when Android::Resources::MoveOp
              to = File.join(res_path, folder, file_op.to)
              DroidProj::Logger.log "Copying #{file_op.from} to #{to}...".green
              FileUtils.cp file_op.from, to
            when Android::Resources::WriteOp
              at = File.join(res_path, folder, file_op.at)
              DroidProj::Logger.log "Writing #{at}...".green
              FileUtils.rm_f at
              File.open(at, 'w') { |f|
                f.write(file_op.content)
              }
            end
          end
        end
      end
    end
  end
end