# Rails AI Promptable

A powerful and flexible gem to integrate AI capabilities into your Rails applications. Support for multiple AI providers including OpenAI, Anthropic (Claude), Google Gemini, Cohere, Azure OpenAI, Mistral AI, and OpenRouter.

[![Gem Version](https://badge.fury.io/rb/rails_ai_promptable.svg)](https://badge.fury.io/rb/rails_ai_promptable)
[![Tests](https://github.com/shoaibmalik786/rails_ai_promptable/workflows/tests/badge.svg)](https://github.com/shoaibmalik786/rails_ai_promptable/actions)

## Features

- 🚀 **Multiple AI Providers**: OpenAI, Anthropic, Gemini, Cohere, Azure OpenAI, Mistral, OpenRouter
- 🔌 **Easy Integration**: Include in any Rails model or service
- 📝 **Template System**: Simple prompt templating with variable interpolation
- ⚡ **Background Processing**: Built-in ActiveJob support for async AI generation
- 🛠️ **Configurable**: Flexible configuration per provider
- 🔒 **Type Safe**: Full test coverage with RSpec
- 🎯 **Rails-First**: Designed specifically for Rails applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_ai_promptable'
```

And then execute:

```bash
bundle install
```

## Quick Start

### 1. Generate Configuration (Recommended)

Run the installation generator to create the configuration file:

```bash
# Default: OpenAI
rails generate rails_ai_promptable:install

# Or specify a different provider
rails generate rails_ai_promptable:install --provider=anthropic
rails generate rails_ai_promptable:install --provider=gemini
rails generate rails_ai_promptable:install --provider=cohere
rails generate rails_ai_promptable:install --provider=azure_openai
rails generate rails_ai_promptable:install --provider=mistral
rails generate rails_ai_promptable:install --provider=openrouter
```

This will create `config/initializers/rails_ai_promptable.rb` with provider-specific configuration.

### 1. Configure Manually (Alternative)

Alternatively, create an initializer `config/initializers/rails_ai_promptable.rb` manually:

```ruby
RailsAIPromptable.configure do |config|
  config.provider = :openai
  config.api_key = ENV['OPENAI_API_KEY']
  config.default_model = 'gpt-4o-mini'
  config.timeout = 30
end
```

### 2. Include in Your Models

```ruby
class Article < ApplicationRecord
  include RailsAIPromptable::Promptable

  # Define a prompt template
  prompt_template "Summarize this article in 3 sentences: %{content}"

  def generate_summary
    ai_generate(context: { content: body })
  end
end
```

### 3. Use in Your Application

```ruby
article = Article.find(1)
summary = article.generate_summary
# => "This article discusses..."
```

## Supported Providers

### OpenAI

```ruby
RailsAIPromptable.configure do |config|
  config.provider = :openai
  config.api_key = ENV['OPENAI_API_KEY']
  config.default_model = 'gpt-4o-mini'
  config.openai_base_url = 'https://api.openai.com/v1' # optional, for custom endpoints
end
```

**Available Models**: `gpt-4o`, `gpt-4o-mini`, `gpt-4-turbo`, `gpt-3.5-turbo`

### Anthropic (Claude)

```ruby
RailsAIPromptable.configure do |config|
  config.provider = :anthropic  # or :claude
  config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
  config.default_model = 'claude-3-5-sonnet-20241022'
end
```

**Available Models**: `claude-3-5-sonnet-20241022`, `claude-3-opus-20240229`, `claude-3-sonnet-20240229`, `claude-3-haiku-20240307`

### Google Gemini

```ruby
RailsAIPromptable.configure do |config|
  config.provider = :gemini  # or :google
  config.gemini_api_key = ENV['GEMINI_API_KEY']
  config.default_model = 'gemini-pro'
end
```

**Available Models**: `gemini-pro`, `gemini-pro-vision`, `gemini-1.5-pro`, `gemini-1.5-flash`

### Cohere

```ruby
RailsAIPromptable.configure do |config|
  config.provider = :cohere
  config.cohere_api_key = ENV['COHERE_API_KEY']
  config.default_model = 'command'
end
```

**Available Models**: `command`, `command-light`, `command-nightly`

### Azure OpenAI

```ruby
RailsAIPromptable.configure do |config|
  config.provider = :azure_openai  # or :azure
  config.azure_api_key = ENV['AZURE_OPENAI_API_KEY']
  config.azure_base_url = ENV['AZURE_OPENAI_BASE_URL'] # e.g., https://your-resource.openai.azure.com
  config.azure_deployment_name = ENV['AZURE_OPENAI_DEPLOYMENT_NAME']
  config.azure_api_version = '2024-02-15-preview' # optional
end
```

### Mistral AI

```ruby
RailsAIPromptable.configure do |config|
  config.provider = :mistral
  config.mistral_api_key = ENV['MISTRAL_API_KEY']
  config.default_model = 'mistral-small-latest'
end
```

**Available Models**: `mistral-large-latest`, `mistral-small-latest`, `mistral-medium-latest`

### OpenRouter

```ruby
RailsAIPromptable.configure do |config|
  config.provider = :openrouter
  config.openrouter_api_key = ENV['OPENROUTER_API_KEY']
  config.openrouter_app_name = 'Your App Name' # optional, for tracking
  config.openrouter_site_url = 'https://yourapp.com' # optional, for attribution
  config.default_model = 'openai/gpt-3.5-turbo'
end
```

**Note**: OpenRouter provides access to multiple models from different providers. See [OpenRouter documentation](https://openrouter.ai/docs) for available models.

## Usage Examples

### Basic Usage

```ruby
class Product < ApplicationRecord
  include RailsAIPromptable::Promptable

  prompt_template "Generate a compelling product description for: %{name}. Features: %{features}"

  def generate_description
    ai_generate(
      context: {
        name: title,
        features: features.join(', ')
      }
    )
  end
end
```

### Custom Model and Temperature

```ruby
class BlogPost < ApplicationRecord
  include RailsAIPromptable::Promptable

  prompt_template "Write a creative blog post about: %{topic}"

  def generate_content
    ai_generate(
      context: { topic: title },
      model: 'gpt-4o',           # Override default model
      temperature: 0.9,          # Higher temperature for more creativity
      format: :text              # Output format
    )
  end
end
```

### Background Processing

For long-running AI tasks, use background processing:

```ruby
class Report < ApplicationRecord
  include RailsAIPromptable::Promptable

  prompt_template "Analyze this data and provide insights: %{data}"

  def generate_analysis
    # Enqueues the AI generation job
    ai_generate_later(
      context: { data: raw_data },
      model: 'gpt-4o'
    )
  end
end
```

### Dynamic Templates

You can set templates dynamically:

```ruby
class ContentGenerator
  include RailsAIPromptable::Promptable

  def generate_with_custom_template(template, context)
    self.class.prompt_template(template)
    ai_generate(context: context)
  end
end

generator = ContentGenerator.new
result = generator.generate_with_custom_template(
  "Translate this to Spanish: %{text}",
  { text: "Hello, world!" }
)
```

### Multiple Providers in One Application

```ruby
# In your initializer
RailsAIPromptable.configure do |config|
  config.provider = :openai
  config.api_key = ENV['OPENAI_API_KEY']

  # Also configure other providers
  config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
  config.gemini_api_key = ENV['GEMINI_API_KEY']
end

# Switch providers at runtime
RailsAIPromptable.configure do |config|
  config.provider = :anthropic
end
RailsAIPromptable.reset_client!  # Reset to use new provider
```

### Service Objects

```ruby
class AIContentService
  include RailsAIPromptable::Promptable

  prompt_template "%{task}"

  def initialize(task)
    @task = task
  end

  def execute
    ai_generate(
      context: { task: @task },
      model: determine_best_model,
      temperature: 0.7
    )
  end

  private

  def determine_best_model
    case RailsAIPromptable.configuration.provider
    when :openai then 'gpt-4o-mini'
    when :anthropic then 'claude-3-5-sonnet-20241022'
    when :gemini then 'gemini-pro'
    else RailsAIPromptable.configuration.default_model
    end
  end
end

# Usage
service = AIContentService.new("Explain quantum computing in simple terms")
result = service.execute
```

## Generator Options

The `rails_ai_promptable:install` generator accepts the following options:

### Available Options

```bash
rails generate rails_ai_promptable:install [options]
```

**--provider**: Specify which AI provider to configure (default: openai)
- `openai` - OpenAI (GPT models)
- `anthropic` or `claude` - Anthropic (Claude models)
- `gemini` or `google` - Google Gemini
- `cohere` - Cohere
- `azure_openai` or `azure` - Azure OpenAI
- `mistral` - Mistral AI
- `openrouter` - OpenRouter (multi-provider gateway)

### What the Generator Creates

The generator creates a configuration file at `config/initializers/rails_ai_promptable.rb` with:

1. **Provider-specific configuration** - Pre-configured settings for your chosen provider
2. **Default model** - Appropriate default model for the provider
3. **Environment variable setup** - Ready-to-use ENV variable references
4. **Comments and examples** - Helpful documentation and usage examples
5. **Multi-provider setup** - Optional configuration for using multiple providers

### Examples

```bash
# Generate config for OpenAI (default)
rails generate rails_ai_promptable:install

# Generate config for Claude/Anthropic
rails generate rails_ai_promptable:install --provider=anthropic

# Generate config for Azure OpenAI
rails generate rails_ai_promptable:install --provider=azure_openai
```

After running the generator, you'll see helpful post-installation instructions guiding you through the next steps.

## Configuration Options

### Global Configuration

```ruby
RailsAIPromptable.configure do |config|
  # Provider Selection
  config.provider = :openai              # Required: AI provider to use

  # Authentication
  config.api_key = ENV['API_KEY']        # Generic API key (fallback)

  # Model Settings
  config.default_model = 'gpt-4o-mini'   # Default model for generation
  config.timeout = 30                     # HTTP timeout in seconds

  # Logging
  config.logger = Rails.logger            # Custom logger

  # Provider-specific settings
  config.openai_base_url = 'https://api.openai.com/v1'
  config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
  config.gemini_api_key = ENV['GEMINI_API_KEY']
  # ... and more
end
```

### Environment Variables

The gem supports the following environment variables:

```bash
# OpenAI
OPENAI_API_KEY=your-key

# Anthropic
ANTHROPIC_API_KEY=your-key

# Google Gemini
GEMINI_API_KEY=your-key

# Cohere
COHERE_API_KEY=your-key

# Azure OpenAI
AZURE_OPENAI_API_KEY=your-key
AZURE_OPENAI_BASE_URL=https://your-resource.openai.azure.com
AZURE_OPENAI_DEPLOYMENT_NAME=your-deployment

# Mistral AI
MISTRAL_API_KEY=your-key

# OpenRouter
OPENROUTER_API_KEY=your-key
OPENROUTER_APP_NAME=your-app-name
OPENROUTER_SITE_URL=https://yourapp.com
```

## API Reference

### Configuration Methods

#### `RailsAIPromptable.configure`
Configure the gem with a block.

```ruby
RailsAIPromptable.configure do |config|
  config.provider = :openai
  config.api_key = 'your-key'
end
```

#### `RailsAIPromptable.client`
Get the current provider client instance.

```ruby
client = RailsAIPromptable.client
# => #<RailsAIPromptable::Providers::OpenAIProvider>
```

#### `RailsAIPromptable.reset_client!`
Reset the memoized client (useful when changing providers).

```ruby
RailsAIPromptable.reset_client!
```

#### `RailsAIPromptable::Providers.available_providers`
Get a list of all supported providers.

```ruby
RailsAIPromptable::Providers.available_providers
# => [:openai, :anthropic, :gemini, :cohere, :azure_openai, :mistral, :openrouter]
```

### Promptable Module Methods

#### `.prompt_template(template)`
Define or retrieve the prompt template for a class.

```ruby
class Article
  include RailsAIPromptable::Promptable
  prompt_template "Summarize: %{content}"
end
```

#### `#ai_generate(context:, model:, temperature:, format:)`
Generate AI content synchronously.

**Parameters:**
- `context` (Hash): Variables to interpolate in the template
- `model` (String, optional): Override the default model
- `temperature` (Float, optional): Control randomness (0.0 - 1.0), defaults to 0.7
- `format` (Symbol, optional): Output format (`:text`, `:json`), defaults to `:text`

**Returns:** String - The generated content

```ruby
result = article.ai_generate(
  context: { content: article.body },
  model: 'gpt-4o',
  temperature: 0.5
)
```

#### `#ai_generate_later(context:, **kwargs)`
Enqueue AI generation as a background job.

```ruby
article.ai_generate_later(
  context: { content: article.body },
  model: 'gpt-4o'
)
```

## Testing

The gem includes comprehensive test coverage. Run tests with:

```bash
bundle exec rspec
```

### Mocking in Tests

```ruby
# In your spec_helper.rb or test setup
RSpec.configure do |config|
  config.before(:each) do
    allow(RailsAIPromptable).to receive(:client).and_return(mock_client)
  end
end

# In your tests
let(:mock_client) { instance_double('Client') }

it 'generates content' do
  allow(mock_client).to receive(:generate).and_return('Generated text')

  result = article.generate_summary
  expect(result).to eq('Generated text')
end
```

## Error Handling

All providers include error handling with logging:

```ruby
class Article < ApplicationRecord
  include RailsAIPromptable::Promptable

  def safe_generate
    result = ai_generate(context: { content: body })

    if result.nil?
      # Check logs for error details
      Rails.logger.error("AI generation failed for Article #{id}")
      "Unable to generate content at this time"
    else
      result
    end
  end
end
```

## Performance Tips

1. **Use Background Jobs**: For non-critical content, use `ai_generate_later`
2. **Choose Appropriate Models**: Smaller models like `gpt-4o-mini` or `claude-3-haiku` are faster
3. **Set Timeouts**: Adjust `timeout` based on your needs
4. **Cache Results**: Consider caching generated content to avoid redundant API calls

```ruby
class Article < ApplicationRecord
  include RailsAIPromptable::Promptable

  def cached_summary
    Rails.cache.fetch("article_summary_#{id}", expires_in: 1.day) do
      ai_generate(context: { content: body })
    end
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shoaibmalik786/rails_ai_promptable.

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RailsAIPromptable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shoaibmalik786/rails_ai_promptable/blob/main/CODE_OF_CONDUCT.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for details on updates and changes.

## Support

- 📚 [Documentation](https://github.com/shoaibmalik786/rails_ai_promptable)
- 🐛 [Issue Tracker](https://github.com/shoaibmalik786/rails_ai_promptable/issues)
- 💬 [Discussions](https://github.com/shoaibmalik786/rails_ai_promptable/discussions)

## Acknowledgments

Special thanks to all contributors and the Ruby on Rails community for their support.
