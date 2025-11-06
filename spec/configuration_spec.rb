# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsAIPromptable::Configuration do
  describe '#initialize' do
    it 'sets default values' do
      config = described_class.new

      expect(config.provider).to eq(:openai)
      expect(config.api_key).to eq(ENV['OPENAI_API_KEY'])
      expect(config.default_model).to eq('gpt-4o-mini')
      expect(config.timeout).to eq(30)
      expect(config.openai_base_url).to eq('https://api.openai.com/v1')
      expect(config.logger).to be_a(RailsAIPromptable::Logger)
    end
  end

  describe 'attribute accessors' do
    let(:config) { described_class.new }

    it 'allows setting and getting provider' do
      config.provider = :anthropic
      expect(config.provider).to eq(:anthropic)
    end

    it 'allows setting and getting api_key' do
      config.api_key = 'test_key_123'
      expect(config.api_key).to eq('test_key_123')
    end

    it 'allows setting and getting default_model' do
      config.default_model = 'gpt-4'
      expect(config.default_model).to eq('gpt-4')
    end

    it 'allows setting and getting timeout' do
      config.timeout = 60
      expect(config.timeout).to eq(60)
    end

    it 'allows setting and getting logger' do
      custom_logger = Logger.new(STDOUT)
      config.logger = custom_logger
      expect(config.logger).to eq(custom_logger)
    end

    it 'allows setting and getting openai_base_url' do
      config.openai_base_url = 'https://custom-openai.com/v1'
      expect(config.openai_base_url).to eq('https://custom-openai.com/v1')
    end

    it 'allows setting and getting anthropic settings' do
      config.anthropic_api_key = 'anthropic_key'
      config.anthropic_base_url = 'https://custom-anthropic.com/v1'
      expect(config.anthropic_api_key).to eq('anthropic_key')
      expect(config.anthropic_base_url).to eq('https://custom-anthropic.com/v1')
    end

    it 'allows setting and getting gemini settings' do
      config.gemini_api_key = 'gemini_key'
      config.gemini_base_url = 'https://custom-gemini.com/v1'
      expect(config.gemini_api_key).to eq('gemini_key')
      expect(config.gemini_base_url).to eq('https://custom-gemini.com/v1')
    end

    it 'allows setting and getting cohere settings' do
      config.cohere_api_key = 'cohere_key'
      config.cohere_base_url = 'https://custom-cohere.com/v1'
      expect(config.cohere_api_key).to eq('cohere_key')
      expect(config.cohere_base_url).to eq('https://custom-cohere.com/v1')
    end

    it 'allows setting and getting azure settings' do
      config.azure_api_key = 'azure_key'
      config.azure_base_url = 'https://test.openai.azure.com'
      config.azure_api_version = '2023-12-01-preview'
      config.azure_deployment_name = 'my-deployment'
      expect(config.azure_api_key).to eq('azure_key')
      expect(config.azure_base_url).to eq('https://test.openai.azure.com')
      expect(config.azure_api_version).to eq('2023-12-01-preview')
      expect(config.azure_deployment_name).to eq('my-deployment')
    end
  end

  describe '#model_for_provider' do
    let(:config) { described_class.new }

    it 'returns correct model for openai' do
      config.provider = :openai
      expect(config.model_for_provider).to eq('gpt-4o-mini')
    end

    it 'returns correct model for anthropic' do
      config.provider = :anthropic
      expect(config.model_for_provider).to eq('claude-3-5-sonnet-20241022')
    end

    it 'returns correct model for gemini' do
      config.provider = :gemini
      expect(config.model_for_provider).to eq('gemini-pro')
    end

    it 'returns correct model for cohere' do
      config.provider = :cohere
      expect(config.model_for_provider).to eq('command')
    end

    it 'returns deployment name for azure_openai when set' do
      config.provider = :azure_openai
      config.azure_deployment_name = 'my-gpt4-deployment'
      expect(config.model_for_provider).to eq('my-gpt4-deployment')
    end

    it 'returns default for azure_openai when deployment name not set' do
      config.provider = :azure_openai
      config.azure_deployment_name = nil
      expect(config.model_for_provider).to eq('gpt-4')
    end

    it 'returns correct model for mistral' do
      config.provider = :mistral
      expect(config.model_for_provider).to eq('mistral-small-latest')
    end

    it 'returns correct model for openrouter' do
      config.provider = :openrouter
      expect(config.model_for_provider).to eq('openai/gpt-3.5-turbo')
    end

    it 'returns default_model for unknown provider' do
      config.provider = :unknown
      config.default_model = 'custom-model'
      expect(config.model_for_provider).to eq('custom-model')
    end
  end
end
