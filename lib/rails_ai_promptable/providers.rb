# frozen_string_literal: true

module RailsAIPromptable
  module Providers
    autoload :BaseProvider, "rails_ai_promptable/providers/base_provider"
    autoload :OpenAIProvider, "rails_ai_promptable/providers/openai_provider"
    autoload :AnthropicProvider, "rails_ai_promptable/providers/anthropic_provider"
    autoload :GeminiProvider, "rails_ai_promptable/providers/gemini_provider"
    autoload :CohereProvider, "rails_ai_promptable/providers/cohere_provider"
    autoload :AzureOpenAIProvider, "rails_ai_promptable/providers/azure_openai_provider"
    autoload :MistralProvider, "rails_ai_promptable/providers/mistral_provider"
    autoload :OpenRouterProvider, "rails_ai_promptable/providers/openrouter_provider"

    def self.for(provider_sym, configuration)
      case provider_sym.to_sym
      when :openai
        OpenAIProvider.new(configuration)
      when :anthropic, :claude
        AnthropicProvider.new(configuration)
      when :gemini, :google
        GeminiProvider.new(configuration)
      when :cohere
        CohereProvider.new(configuration)
      when :azure_openai, :azure
        AzureOpenAIProvider.new(configuration)
      when :mistral
        MistralProvider.new(configuration)
      when :openrouter
        OpenRouterProvider.new(configuration)
      else
        raise ArgumentError,
              "Unknown provider: #{provider_sym}. Supported providers: :openai, :anthropic, :gemini, :cohere, :azure_openai, :mistral, :openrouter"
      end
    end

    # Helper method to list all available providers
    def self.available_providers
      %i[openai anthropic gemini cohere azure_openai mistral openrouter]
    end
  end
end
