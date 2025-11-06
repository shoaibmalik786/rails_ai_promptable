# frozen_string_literal: true

require_relative "lib/rails_ai_promptable/version"

Gem::Specification.new do |spec|
  spec.name          = "rails_ai_promptable"
  spec.version       = RailsAIPromptable::VERSION
  spec.authors       = ["Shoaib Malik"]
  spec.email         = ["shoaib2109@gmail.com"]

  spec.summary       = "Add AI promptable behavior to your Rails models and classes."
  spec.description   = "rails_ai_promptable makes it easy to integrate AI-driven features into your Rails application. It allows you to define promptable methods, chain context, and connect with AI APIs like OpenAI, Anthropic, or local LLMs with minimal setup."
  spec.homepage      = "https://github.com/shoaibmalik786/rails_ai_promptable"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = "https://github.com/shoaibmalik786/rails_ai_promptable"
  spec.metadata["changelog_uri"]     = "https://github.com/shoaibmalik786/rails_ai_promptable/blob/main/CHANGELOG.md"

  # Files included in the gem
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "httparty", ">= 0.20"
end
