# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAIPromptable::Providers do
  let(:configuration) { RailsAIPromptable::Configuration.new }

  describe ".for" do
    context "when provider is :openai" do
      it "returns an OpenAIProvider instance" do
        provider = described_class.for(:openai, configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::OpenAIProvider)
      end
    end

    context "when provider is openai as string" do
      it "returns an OpenAIProvider instance" do
        provider = described_class.for("openai", configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::OpenAIProvider)
      end
    end

    context "when provider is :anthropic" do
      it "returns an AnthropicProvider instance" do
        provider = described_class.for(:anthropic, configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::AnthropicProvider)
      end
    end

    context "when provider is :claude" do
      it "returns an AnthropicProvider instance" do
        provider = described_class.for(:claude, configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::AnthropicProvider)
      end
    end

    context "when provider is :gemini" do
      it "returns a GeminiProvider instance" do
        provider = described_class.for(:gemini, configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::GeminiProvider)
      end
    end

    context "when provider is :google" do
      it "returns a GeminiProvider instance" do
        provider = described_class.for(:google, configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::GeminiProvider)
      end
    end

    context "when provider is :cohere" do
      it "returns a CohereProvider instance" do
        provider = described_class.for(:cohere, configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::CohereProvider)
      end
    end

    context "when provider is :azure_openai" do
      before do
        configuration.azure_base_url = "https://test.openai.azure.com"
      end

      it "returns an AzureOpenAIProvider instance" do
        provider = described_class.for(:azure_openai, configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::AzureOpenAIProvider)
      end
    end

    context "when provider is :azure" do
      before do
        configuration.azure_base_url = "https://test.openai.azure.com"
      end

      it "returns an AzureOpenAIProvider instance" do
        provider = described_class.for(:azure, configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::AzureOpenAIProvider)
      end
    end

    context "when provider is :mistral" do
      it "returns a MistralProvider instance" do
        provider = described_class.for(:mistral, configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::MistralProvider)
      end
    end

    context "when provider is :openrouter" do
      it "returns an OpenRouterProvider instance" do
        provider = described_class.for(:openrouter, configuration)
        expect(provider).to be_a(RailsAIPromptable::Providers::OpenRouterProvider)
      end
    end

    context "when provider is unknown" do
      it "raises an ArgumentError with helpful message" do
        expect do
          described_class.for(:unknown, configuration)
        end.to raise_error(ArgumentError, /Unknown provider: unknown.*Supported providers/)
      end
    end
  end

  describe ".available_providers" do
    it "returns an array of available provider symbols" do
      expect(described_class.available_providers).to eq(%i[openai anthropic gemini cohere azure_openai
                                                           mistral openrouter])
    end
  end
end

RSpec.describe RailsAIPromptable::Providers::BaseProvider do
  let(:configuration) { RailsAIPromptable::Configuration.new }
  let(:provider) { described_class.new(configuration) }

  describe "#initialize" do
    it "stores the configuration" do
      expect(provider.instance_variable_get(:@config)).to eq(configuration)
    end
  end

  describe "#generate" do
    it "raises NotImplementedError" do
      expect do
        provider.generate(prompt: "test", model: "gpt-4", temperature: 0.7, format: :text)
      end.to raise_error(NotImplementedError)
    end
  end
end

RSpec.describe RailsAIPromptable::Providers::OpenAIProvider do
  let(:configuration) do
    config = RailsAIPromptable::Configuration.new
    config.api_key = "test_api_key"
    config
  end
  let(:provider) { described_class.new(configuration) }

  describe "#initialize" do
    it "stores the api_key from configuration" do
      expect(provider.instance_variable_get(:@api_key)).to eq("test_api_key")
    end

    it "stores the base_url from configuration" do
      expect(provider.instance_variable_get(:@base_url)).to eq("https://api.openai.com/v1")
    end

    it "stores the timeout from configuration" do
      expect(provider.instance_variable_get(:@timeout)).to eq(30)
    end
  end

  describe "#generate" do
    let(:prompt) { "Tell me a joke" }
    let(:model) { "gpt-4o-mini" }
    let(:temperature) { 0.7 }
    let(:format) { :text }

    before do
      # Configure RailsAIPromptable for logging
      RailsAIPromptable.configure do |config|
        config.api_key = "test_api_key"
      end
    end

    context "when the API call succeeds" do
      it "returns the generated content" do
        stub_request(:post, "https://api.openai.com/v1/chat/completions")
          .with(
            body: {
              model: model,
              messages: [{ role: "user", content: prompt }],
              temperature: temperature
            }.to_json,
            headers: {
              "Content-Type" => "application/json",
              "Authorization" => "Bearer test_api_key"
            }
          )
          .to_return(
            status: 200,
            body: {
              choices: [
                {
                  message: {
                    content: "Why did the chicken cross the road?"
                  }
                }
              ]
            }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        result = provider.generate(
          prompt: prompt,
          model: model,
          temperature: temperature,
          format: format
        )

        expect(result).to eq("Why did the chicken cross the road?")
      end
    end

    context "when the API call fails" do
      it "logs the error and returns nil" do
        stub_request(:post, "https://api.openai.com/v1/chat/completions")
          .to_raise(StandardError.new("Network error"))

        result = provider.generate(
          prompt: prompt,
          model: model,
          temperature: temperature,
          format: format
        )

        expect(result).to be_nil
      end
    end

    context "when the API returns an error response" do
      it "logs the error and returns nil" do
        stub_request(:post, "https://api.openai.com/v1/chat/completions")
          .to_return(
            status: 500,
            body: { error: "Internal server error" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        result = provider.generate(
          prompt: prompt,
          model: model,
          temperature: temperature,
          format: format
        )

        expect(result).to be_nil
      end
    end
  end
end
