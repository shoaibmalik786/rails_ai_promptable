# frozen_string_literal: true

require 'spec_helper'
require 'generators/rails_ai_promptable/install_generator'
require 'rails/generators/test_case'

RSpec.describe RailsAiPromptable::Generators::InstallGenerator, type: :generator do
  destination File.expand_path('../../../tmp/generator_test', __FILE__)

  before(:all) do
    prepare_destination
  end

  after(:each) do
    FileUtils.rm_rf(destination_root) if File.exist?(destination_root)
  end

  describe 'with default options (openai)' do
    before do
      run_generator
    end

    it 'creates the initializer file' do
      expect(File.exist?(file('config/initializers/rails_ai_promptable.rb'))).to be true
    end

    it 'configures openai as the provider' do
      content = File.read(file('config/initializers/rails_ai_promptable.rb'))
      expect(content).to include('config.provider = :openai')
      expect(content).to include("ENV['OPENAI_API_KEY']")
      expect(content).to include('gpt-4o-mini')
    end

    it 'includes general configuration settings' do
      content = File.read(file('config/initializers/rails_ai_promptable.rb'))
      expect(content).to include('config.timeout = 30')
      expect(content).to include('RailsAIPromptable.configure')
    end
  end

  describe 'with anthropic provider option' do
    before do
      run_generator ['--provider=anthropic']
    end

    it 'creates the initializer with anthropic configuration' do
      content = File.read(file('config/initializers/rails_ai_promptable.rb'))
      expect(content).to include('config.provider = :anthropic')
      expect(content).to include("ENV['ANTHROPIC_API_KEY']")
      expect(content).to include('claude-3-5-sonnet-20241022')
    end
  end

  describe 'with gemini provider option' do
    before do
      run_generator ['--provider=gemini']
    end

    it 'creates the initializer with gemini configuration' do
      content = File.read(file('config/initializers/rails_ai_promptable.rb'))
      expect(content).to include('config.provider = :gemini')
      expect(content).to include("ENV['GEMINI_API_KEY']")
      expect(content).to include('gemini-pro')
    end
  end

  describe 'with cohere provider option' do
    before do
      run_generator ['--provider=cohere']
    end

    it 'creates the initializer with cohere configuration' do
      content = File.read(file('config/initializers/rails_ai_promptable.rb'))
      expect(content).to include('config.provider = :cohere')
      expect(content).to include("ENV['COHERE_API_KEY']")
      expect(content).to include('command')
    end
  end

  describe 'with azure_openai provider option' do
    before do
      run_generator ['--provider=azure_openai']
    end

    it 'creates the initializer with azure configuration' do
      content = File.read(file('config/initializers/rails_ai_promptable.rb'))
      expect(content).to include('config.provider = :azure_openai')
      expect(content).to include("ENV['AZURE_OPENAI_API_KEY']")
      expect(content).to include('azure_base_url')
      expect(content).to include('azure_deployment_name')
    end
  end

  describe 'with mistral provider option' do
    before do
      run_generator ['--provider=mistral']
    end

    it 'creates the initializer with mistral configuration' do
      content = File.read(file('config/initializers/rails_ai_promptable.rb'))
      expect(content).to include('config.provider = :mistral')
      expect(content).to include("ENV['MISTRAL_API_KEY']")
      expect(content).to include('mistral-small-latest')
    end
  end

  describe 'with openrouter provider option' do
    before do
      run_generator ['--provider=openrouter']
    end

    it 'creates the initializer with openrouter configuration' do
      content = File.read(file('config/initializers/rails_ai_promptable.rb'))
      expect(content).to include('config.provider = :openrouter')
      expect(content).to include("ENV['OPENROUTER_API_KEY']")
      expect(content).to include('openai/gpt-3.5-turbo')
      expect(content).to include('openrouter_app_name')
      expect(content).to include('openrouter_site_url')
    end
  end

  private

  def file(path)
    File.join(destination_root, path)
  end

  def prepare_destination
    FileUtils.mkdir_p(destination_root)
  end
end
