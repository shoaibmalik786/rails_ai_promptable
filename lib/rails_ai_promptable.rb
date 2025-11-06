# frozen_string_literal: true

require "rails_ai_promptable/version"
require "rails_ai_promptable/configuration"
require "rails_ai_promptable/template_registry"
require "rails_ai_promptable/promptable"
require "rails_ai_promptable/providers"
require "rails_ai_promptable/logger"
require "rails_ai_promptable/background_job"

module RailsAIPromptable
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def client
      @client ||= Providers.for(configuration.provider, configuration)
    end

    def reset_client!
      @client = nil
    end
  end
end
