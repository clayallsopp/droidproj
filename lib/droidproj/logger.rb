module DroidProj
  class Logger
    class << self
      def log(message)
        logger.log(message)
      end

      def logger
        @logger ||= new
      end
    end

    attr_accessor :enabled

    def initialize
      @enabled = true
    end

    def log(message)
      puts message.green if self.enabled
    end
  end
end