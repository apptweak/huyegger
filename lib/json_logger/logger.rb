require "json_logger/formatter"

module JsonLogger
  module Logger
    def context(*args)
      formatter.set_context(*args)
    end

    def add_fields_to_context(fields)
      formatter.add_fields_to_context(fields)
    end

    def clear_context!
      formatter.clear_context!
    end

    def display(properties)
      if properties.is_a?(Hash)
        properties.each do |key, value|
          formatter.class.set_property_to_display(key, value)
        end
      end
      return self
    end

    def child_logger
      return self.clone()
    end

    def silencer
      @silencer = true if @silencer.nil?
      return @silencer
    end

    def silencer=(value)
      @silencer = value
    end

    def silence(temporary_level = self.class::ERROR)
      if silencer
        begin
          old_logger_level, self.level = level, temporary_level 
          yield self
        ensure
          self.level = old_logger_level
        end
      else
        yield self
      end
    end

    def self.new(logger, framework=nil)
      if framework and framework.is_a?(String)
        logger.formatter = JsonLogger::Formatter.new(logger.formatter, framework.upcase)
      else
        logger.formatter = JsonLogger::Formatter.new(logger.formatter)
      end
      logger.extend(self)
    end
  end
end
