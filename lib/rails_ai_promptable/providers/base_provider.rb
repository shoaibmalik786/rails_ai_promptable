# frozen_string_literal: true

module RailsAIPromptable
  module Providers
    class BaseProvider
      def initialize(configuration)
        @config = configuration
      end

      def generate(prompt:, model:, temperature:, format:)
        raise NotImplementedError
      end
    end
  end
end
