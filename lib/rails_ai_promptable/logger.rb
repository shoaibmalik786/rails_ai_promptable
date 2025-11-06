# frozen_string_literal: true
require 'logger'

module RailsAIPromptable
  class Logger
    def initialize(io = $stdout)
      @logger = ::Logger.new(io)
    end

    def info(msg)
      @logger.info(msg)
    end

    def error(msg)
      @logger.error(msg)
    end
  end
end
