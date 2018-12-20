module JsonLogger
  module Middlewares
    class Rails
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      ensure
        ::Rails.logger.clear_context! if defined?(JsonLogger) && ::Rails.logger.is_a?(JsonLogger::Logger)
      end
    end
  end
end
