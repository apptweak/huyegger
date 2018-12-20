module JsonLogger
  module Middlewares
    class Sidekiq
      def call(worker, msg, queue)
        ::Rails.logger.clear_context! if defined?(JsonLogger) && ::Rails.logger.is_a?(JsonLogger::Logger)
        yield
      end
    end
  end
end
