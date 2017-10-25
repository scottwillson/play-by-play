require "logger"

module PlayByPlay
  @logger = nil
  @environment = nil

  def self.environment
    @environment = ENV["RACK_ENV"]&.to_sym || :development
  end

  def self.logger
    @logger ||= new_logger
  end

  def self.new_logger
    logger = Logger.new(STDERR)

    if ENV["DEBUG"]
      logger.level = :debug
    elsif environment == :test
      logger.level = :fatal
    else
      logger.level = :info
    end

    logger.formatter = proc do |severity, datetime, _, msg|
      "severity: #{severity}, timestamp: #{datetime.utc}, #{msg}\n"
    end

    logger
  end
end
