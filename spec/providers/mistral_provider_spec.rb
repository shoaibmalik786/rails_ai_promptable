# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAIPromptable::Providers::MistralProvider do
  let(:configuration) do
    config = RailsAIPromptable::Configuration.new
    config.mistral_api_key = "test_mistral_key"
    config
  end
  let(:provider) { described_class.new(configuration) }

  describe "#initialize" do
    it "stores the mistral_api_key from configuration" do
      expect(provider.instance_variable_get(:@api_key)).to eq("test_mistral_key")
    end

    it "stores the base_url from configuration" do
      expect(provider.instance_variable_get(:@base_url)).to eq("https://api.mistral.ai/v1")
    end

    it "stores the timeout from configuration" do
      expect(provider.instance_variable_get(:@timeout)).to eq(30)
    end

    it "falls back to generic api_key if mistral_api_key is not set" do
      config = RailsAIPromptable::Configuration.new
      config.api_key = "generic_key"
      config.mistral_api_key = nil
      provider = described_class.new(config)
      expect(provider.instance_variable_get(:@api_key)).to eq("generic_key")
    end

    it "allows custom base_url" do
      configuration.mistral_base_url = "https://custom-mistral.com/v1"
      provider = described_class.new(configuration)
      expect(provider.instance_variable_get(:@base_url)).to eq("https://custom-mistral.com/v1")
    end
  end

  describe "#generate" do
    let(:prompt) { "Tell me a joke" }
    let(:model) { "mistral-small-latest" }
    let(:temperature) { 0.7 }
    let(:format) { :text }

    before do
      RailsAIPromptable.configure do |config|
        config.mistral_api_key = "test_mistral_key"
      end
    end

    context "when the API call succeeds" do
      it "returns the generated content" do
        stub_request(:post, "https://api.mistral.ai/v1/chat/completions")
          .with(
            body: hash_including({
                                   model: model,
                                   messages: [{ role: "user", content: prompt }],
                                   temperature: temperature,
                                   max_tokens: 2048
                                 }),
            headers: {
              "Content-Type" => "application/json",
              "Authorization" => "Bearer test_mistral_key"
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
        stub_request(:post, "https://api.mistral.ai/v1/chat/completions")
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
        stub_request(:post, "https://api.mistral.ai/v1/chat/completions")
          .to_return(
            status: 401,
            body: {
              message: "Unauthorized"
            }.to_json,
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
