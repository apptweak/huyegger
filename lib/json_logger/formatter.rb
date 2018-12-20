# frozen_string_literal: true
require "logger"
require "time"
require "binding_of_caller"

module JsonLogger
  class Formatter
    SEVERITY_STR = {
      ::Logger::DEBUG => "DEBUG",
      ::Logger::INFO => "INFO",
      ::Logger::WARN => "WARN",
      ::Logger::ERROR => "ERROR",
      ::Logger::FATAL => "FATAL",
      ::Logger::UNKNOWN => "UNKNOWN"
    }

    RAILS_LEVEL_CALLER = 9
    DEFAULT_LEVEL_CALLER = 7
    RAILS = "RAILS"

    DEFAULT_PROPERTIES_TO_DISPLAY = {
      :caller_method => false,
      :caller_params => false,
      :caller_location => false,
      :backtrace => false
    }

    ARGS_TO_HASH = "method(__method__).parameters.map { |arg| { :name => arg[1].to_s, :value => eval(arg[1].to_s) } }"

    attr_reader :original_formatter

    def initialize(original_formatter, framework=nil)
      @original_formatter = original_formatter
      @framework = framework
    end

    def clear_context!
      __context__.clear
    end

    def add_fields_to_context(fields)
      __context__.merge!(fields) unless (fields.nil? or ! fields.is_a?(Hash))
    end

    def set_context(context)
      if context
        clear_context!
        add_fields_to_context(context)
      end
    end

    # This method is invoked when a log event occurs
    def call(severity, timestamp, progname, msg)
      msg = original_formatter.call(severity, timestamp, progname, msg) if original_formatter && String === msg
      json_message = {}

      add_severity!(json_message, severity)
      json_message.merge!(JsonLogger.stringify_keys(__context__))
      add_message!(json_message, msg)
      add_timestamp(json_message)

      self.class.properties_to_display.each do |property, to_display|
        if to_display
          add_property!(json_message, property)
        end
      end
      self.class.reset_properties_to_display

      "#{JsonLogger.json_encoder.call(json_message)}\n"
    end

    def self.properties_to_display
      @@properties_to_display ||= DEFAULT_PROPERTIES_TO_DISPLAY.clone
    end

    def self.set_property_to_display(property, to_display)
      if property and to_display and (property.is_a?(String) or property.is_a?(Symbol)) and self.properties_to_display.has_key?(property.to_sym)
        self.properties_to_display[property.to_sym] = to_display unless (to_display != true and to_display != false)
      end
    end

    def self.reset_properties_to_display
      @@properties_to_display = DEFAULT_PROPERTIES_TO_DISPLAY.clone
    end

    private

    def add_severity!(json_message, severity)
      case severity
      when String
        json_message.merge!("level" => severity)
      when Integer
        json_message.merge!("level" => SEVERITY_STR.fetch(severity))
      else
        json_message.merge!("level" => SEVERITY_STR.fetch(::Logger::UNKNOWN))
      end
    end

    def add_message!(json_message, msg)
      case msg
      when String
        json_message.merge!("message" => msg)
      when Hash
        json_message.merge!("message" => "Empty message") # default message because it is required
        json_message.merge!(JsonLogger.stringify_keys(msg))
      else
        json_message.merge!("message" => msg.inspect)
      end
    end

    def add_property!(json_message, property)
      case property
      when :caller_method
        method_name = caller_locations(caller_level,1)[0].label
        json_message.merge!("caller_method" => method_name)
      when :caller_params
        params = binding.of_caller(caller_level - 1).eval(ARGS_TO_HASH)
        json_message.merge!("caller_params" => params)
      when :caller_location
        location = caller[caller_level].split(':in')[0]
        json_message.merge!("caller_location" => location)
      when :backtrace
        backtrace = caller.slice(caller_level..-1)
        json_message.merge!("backtrace" => backtrace)
      end
    end

    def add_timestamp(json_message)
      json_message['timestamp'] ||= Time.now.xmlschema
    end

    def __context__
      # Use object_id to avoid conflicts with other instances
      Thread.current[:"__json_logger_context__#{object_id}"] ||= {}
    end

    def caller_level()
      if @framework == RAILS
        return RAILS_LEVEL_CALLER
      else
        return DEFAULT_LEVEL_CALLER
      end
    end
  end
end
