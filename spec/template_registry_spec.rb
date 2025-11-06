# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'tmpdir'

RSpec.describe RailsAIPromptable::TemplateRegistry do
  before(:each) do
    described_class.clear!
  end

  after(:each) do
    described_class.clear!
  end

  describe '.register' do
    it 'registers a template with a name' do
      described_class.register(:summary, 'Summarize: %{text}')
      expect(described_class.get(:summary)).to eq('Summarize: %{text}')
    end

    it 'converts string names to symbols' do
      described_class.register('summary', 'Summarize: %{text}')
      expect(described_class.get(:summary)).to eq('Summarize: %{text}')
    end

    it 'overwrites existing templates with same name' do
      described_class.register(:summary, 'Old template')
      described_class.register(:summary, 'New template')
      expect(described_class.get(:summary)).to eq('New template')
    end
  end

  describe '.get' do
    it 'returns nil for unregistered template' do
      expect(described_class.get(:nonexistent)).to be_nil
    end

    it 'retrieves registered templates' do
      described_class.register(:greeting, 'Hello %{name}')
      expect(described_class.get(:greeting)).to eq('Hello %{name}')
    end
  end

  describe '.load_from_file' do
    it 'loads templates from a YAML file' do
      Tempfile.create(['templates', '.yml']) do |file|
        file.write({
          'summary' => 'Summarize: %{content}',
          'greeting' => 'Hello %{name}'
        }.to_yaml)
        file.rewind

        described_class.load_from_file(file.path)

        expect(described_class.get(:summary)).to eq('Summarize: %{content}')
        expect(described_class.get(:greeting)).to eq('Hello %{name}')
      end
    end

    it 'does nothing if file does not exist' do
      expect {
        described_class.load_from_file('/nonexistent/file.yml')
      }.not_to raise_error
    end

    it 'handles invalid YAML gracefully' do
      Tempfile.create(['invalid', '.yml']) do |file|
        file.write("not: valid: yaml:")
        file.rewind

        expect {
          described_class.load_from_file(file.path)
        }.not_to raise_error
      end
    end
  end

  describe '.load_from_directory' do
    it 'loads templates from text files in directory' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'summary.txt'), 'Summarize: %{content}')
        File.write(File.join(dir, 'greeting.txt'), 'Hello %{name}')

        described_class.load_from_directory(dir)

        expect(described_class.get(:summary)).to eq('Summarize: %{content}')
        expect(described_class.get(:greeting)).to eq('Hello %{name}')
      end
    end

    it 'loads templates from YAML files in directory' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'summary.yml'), { 'template' => 'Summarize: %{content}' }.to_yaml)

        described_class.load_from_directory(dir)

        expect(described_class.get(:summary)).to eq('Summarize: %{content}')
      end
    end

    it 'does nothing if directory does not exist' do
      expect {
        described_class.load_from_directory('/nonexistent/directory')
      }.not_to raise_error
    end

    it 'skips non-file entries' do
      Dir.mktmpdir do |dir|
        Dir.mkdir(File.join(dir, 'subdir'))
        File.write(File.join(dir, 'template.txt'), 'Test template')

        described_class.load_from_directory(dir)

        expect(described_class.get(:template)).to eq('Test template')
      end
    end
  end

  describe '.clear!' do
    it 'removes all registered templates' do
      described_class.register(:template1, 'Template 1')
      described_class.register(:template2, 'Template 2')

      described_class.clear!

      expect(described_class.get(:template1)).to be_nil
      expect(described_class.get(:template2)).to be_nil
    end
  end

  describe '.list' do
    it 'returns empty array when no templates registered' do
      expect(described_class.list).to eq([])
    end

    it 'returns all registered template names' do
      described_class.register(:summary, 'Summary template')
      described_class.register(:greeting, 'Greeting template')
      described_class.register(:translation, 'Translation template')

      expect(described_class.list).to contain_exactly(:summary, :greeting, :translation)
    end
  end

  describe '.templates' do
    it 'returns the templates hash' do
      described_class.register(:test, 'Test template')
      expect(described_class.templates).to be_a(Hash)
      expect(described_class.templates[:test]).to eq('Test template')
    end
  end
end
