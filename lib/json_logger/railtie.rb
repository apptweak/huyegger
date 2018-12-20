require "json_logger/middlewares/rails"

module JsonLogger
  class Railtie < ::Rails::Railtie
    initializer "json_logger.insert_middleware" do |app|
      if ActionDispatch.const_defined? :RequestId
        app.config.middleware.insert_after ActionDispatch::RequestId, JsonLogger::Middlewares::Rails
      else
        app.config.middleware.insert_after Rack::MethodOverride, JsonLogger::Middlewares::Rails
      end

      if ActiveSupport.const_defined?(:Reloader) && ActiveSupport::Reloader.respond_to?(:to_complete)
        ActiveSupport::Reloader.to_complete do
          ::Rails.logger.clear_context! if ::Rails.logger.is_a?(JsonLogger::Logger)
        end
      elsif ActionDispatch.const_defined?(:Reloader) && ActionDispatch::Reloader.respond_to?(:to_cleanup)
        ActionDispatch::Reloader.to_cleanup do
          ::Rails.logger.clear_context! if ::Rails.logger.is_a?(JsonLogger::Logger)
        end
      end
    end
  end
end
