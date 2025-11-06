# frozen_string_literal: true

module RailsAIPromptable
  class Configuration
    attr_accessor :provider, :api_key, :default_model, :timeout, :logger,
                  # OpenAI
                  :openai_base_url,
                  # Anthropic/Claude
                  :anthropic_api_key, :anthropic_base_url,
                  # Google Gemini
                  :gemini_api_key, :gemini_base_url,
                  # Cohere
                  :cohere_api_key, :cohere_base_url,
                  # Azure OpenAI
                  :azure_api_key, :azure_base_url, :azure_api_version, :azure_deployment_name,
                  # Mistral AI
                  :mistral_api_key, :mistral_base_url,
                  # OpenRouter
                  :openrouter_api_key, :openrouter_base_url, :openrouter_app_name, :openrouter_site_url

    def initialize
      @provider = :openai
      @api_key = ENV['OPENAI_API_KEY']
      @default_model = 'gpt-4o-mini'
      @timeout = 30
      @logger = Logger.new($stdout)

      # OpenAI settings
      @openai_base_url = 'https://api.openai.com/v1'

      # Anthropic settings
      @anthropic_api_key = ENV['ANTHROPIC_API_KEY']
      @anthropic_base_url = 'https://api.anthropic.com/v1'

      # Gemini settings
      @gemini_api_key = ENV['GEMINI_API_KEY']
      @gemini_base_url = 'https://generativelanguage.googleapis.com/v1beta'

      # Cohere settings
      @cohere_api_key = ENV['COHERE_API_KEY']
      @cohere_base_url = 'https://api.cohere.ai/v1'

      # Azure OpenAI settings
      @azure_api_key = ENV['AZURE_OPENAI_API_KEY']
      @azure_base_url = ENV['AZURE_OPENAI_BASE_URL']
      @azure_api_version = '2024-02-15-preview'
      @azure_deployment_name = ENV['AZURE_OPENAI_DEPLOYMENT_NAME']

      # Mistral AI settings
      @mistral_api_key = ENV['MISTRAL_API_KEY']
      @mistral_base_url = 'https://api.mistral.ai/v1'

      # OpenRouter settings
      @openrouter_api_key = ENV['OPENROUTER_API_KEY']
      @openrouter_base_url = 'https://openrouter.ai/api/v1'
      @openrouter_app_name = ENV['OPENROUTER_APP_NAME']
      @openrouter_site_url = ENV['OPENROUTER_SITE_URL']
    end

    # Helper method to get the appropriate default model for the current provider
    def model_for_provider
      case provider.to_sym
      when :openai
        'gpt-4o-mini'
      when :anthropic
        'claude-3-5-sonnet-20241022'
      when :gemini
        'gemini-pro'
      when :cohere
        'command'
      when :azure_openai
        azure_deployment_name || 'gpt-4'
      when :mistral
        'mistral-small-latest'
      when :openrouter
        'openai/gpt-3.5-turbo'
      else
        default_model
      end
    end
  end
end
