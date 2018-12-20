module JsonLogger
  module Middlewares
    class RackLogger

      def initialize(app, logger)
        @app = app
        @logger = logger
      end

      def call(env)
        began_at = Time.now
        # Clear the logger context before each request
        @logger.clear_context! if valid_logger?
        status, header, body = @app.call(env)
        # Log the request
        log(env, status, header, began_at) if valid_logger?
        [status, header, body]
      end

      private

      def valid_logger?
        return !@logger.nil? && defined?(JsonLogger) && @logger.is_a?(JsonLogger::Logger)
      end

      def log(env, status, header, began_at)
        now = Time.now
        length = extract_content_length(header)

        params = query_string_to_array(env["QUERY_STRING"])

        msg = {
          "message" => "request",
          "remote_addr" => (env["HTTP_X_FORWARDED_FOR"] || env["REMOTE_ADDR"] || "-"),
          "remote_user" => (env["REMOTE_USER"] || "-"),
          "time" => now.strftime("%d/%b/%Y:%H:%M:%S %z"),
          "request_method" => env["REQUEST_METHOD"],
          "path" => env["PATH_INFO"],
          "params" => (params),
          "http_version" => env["HTTP_VERSION"],
          "status_code" => status.to_s[0..3],
          "length" => length,
          "duration" => (now - began_at)
        }
        
        if status >= 400
          @logger.error(msg)
        elsif status >= 300
          @logger.warn(msg)
        else
           @logger.info(msg)
        end

      end

      def extract_content_length(headers)
        value = headers["Content-Length"] or return '-'
        value.to_s == '0' ? '-' : value
      end

      def query_string_to_array(query_string)
        res = []
        query_string.split("&").each do |param|
          param_name, param_value = param.split("=")
          res << {"name" => param_name, "value" => param_value}
        end
        return res
      end
    end
  end
end
