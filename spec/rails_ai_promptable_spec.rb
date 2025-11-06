# frozen_string_literal: true

RSpec.describe RailsAIPromptable do
  it "has a version number" do
    expect(RailsAIPromptable::VERSION).not_to be_nil
  end

  it "has VERSION constant in correct format" do
    expect(RailsAIPromptable::VERSION).to match(/\d+\.\d+\.\d+/)
  end

  it "responds to promptable module" do
    expect(defined?(RailsAIPromptable::Promptable)).to be_truthy
  end

  describe ".configure" do
    it "yields configuration block" do
      RailsAIPromptable.configure do |config|
        config.provider = :openai
        config.api_key = "test_key"
      end

      expect(RailsAIPromptable.configuration.provider).to eq(:openai)
      expect(RailsAIPromptable.configuration.api_key).to eq("test_key")
    end

    it "creates configuration if not exists" do
      RailsAIPromptable.configuration = nil
      RailsAIPromptable.configure

      expect(RailsAIPromptable.configuration).to be_a(RailsAIPromptable::Configuration)
    end
  end

  describe ".client" do
    before do
      RailsAIPromptable.configuration = nil
      RailsAIPromptable.reset_client!
    end

    it "returns a provider client" do
      RailsAIPromptable.configure do |config|
        config.provider = :openai
        config.api_key = "test_key"
      end

      client = RailsAIPromptable.client
      expect(client).to be_a(RailsAIPromptable::Providers::OpenAIProvider)
    end

    it "memoizes the client" do
      RailsAIPromptable.configure do |config|
        config.provider = :openai
      end

      client1 = RailsAIPromptable.client
      client2 = RailsAIPromptable.client

      expect(client1).to be(client2)
    end
  end

  describe ".reset_client!" do
    it "resets the memoized client" do
      RailsAIPromptable.configure do |config|
        config.provider = :openai
      end

      client1 = RailsAIPromptable.client
      RailsAIPromptable.reset_client!
      client2 = RailsAIPromptable.client

      expect(client1).not_to be(client2)
    end
  end
end
