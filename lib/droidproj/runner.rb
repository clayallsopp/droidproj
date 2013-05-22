module DroidProj
  class Runner
    POSSIBLE_FILES = [
      'droidfile',
      'Droidfile',
      'droidfile.rb',
      'Droidfile.rb'
    ].freeze

    attr_accessor :droidfile, :app

    class << self
      def run
        new.run
      end
    end

    def initialize
      @possible_files = POSSIBLE_FILES.dup
    end

    def run
      @droidfile = find_droidfile_location

      raise "You need to supply a Droidfile in the current directory" if !@droidfile

      @app = DroidProj::Android::App.new(File.dirname(@droidfile))

      DroidProj::Logger.log "Evaluating Droidfile...".green
      eval_droidfile

      DroidProj::Logger.log "Creating filesystem...".green
      @app.create_filesystem!

      DroidProj::Logger.log "Done!".green
    end

    def eval_droidfile
      content = nil
      File.open(@droidfile, 'r') {|file|
        content = file.read
      }

      context = RunnerContext.new
      context.app = @app

      eval content, context.create_context.binding
    end

    def find_droidfile_location
      @possible_files.each do |file|
        return file if File.exist?(file)
      end
      nil
    end
  end

  class RunnerContext
    attr_accessor :app

    def create_context
      Proc.new {}
    end

    def method_missing(method, *args, &block)
      if app.respond_to?(method)
        app.send(method, *args, &block)
      else
        super
      end
    end
  end
end