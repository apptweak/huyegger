require "test_helper"
require "json"
require "timecop"

class JsonLogger::LoggerTest < Minitest::Test
  def setup
    @io = StringIO.new
    @logger = Logger.new(@io)
    @logger.level = Logger::DEBUG
    @json_logger = JsonLogger::Logger.new(@logger)
    @time = Timecop.freeze
  end

  def teardown
    Timecop.return
  end

  def output
    @io.string.chomp
  end

  def test_logger
    assert_respond_to(@json_logger, :context)
    assert_respond_to(@json_logger, :clear_context!)
  end

  def test_output
    @json_logger.info("test")
    assert_equal(output, { level: "INFO", message: "test", timestamp: @time.xmlschema }.to_json)
  end

  def test_message_key
    @json_logger.info(message: "log message")
    assert_equal(output, { level: "INFO", message: "log message", timestamp: @time.xmlschema }.to_json)
  end

  def test_level
    @logger.level = Logger::FATAL
    @json_logger.info("test")
    assert_equal(output, "")
  end

  def test_context
    @json_logger.context(meta: "metadata")
    @json_logger.info("test")
    assert_equal(output, { level: "INFO", meta: "metadata", message: "test", timestamp: @time.xmlschema }.to_json)
  end
end
