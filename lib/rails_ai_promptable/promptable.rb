# frozen_string_literal: true

require 'active_support/concern'

module RailsAIPromptable
  module Promptable
    extend ActiveSupport::Concern

    included do
      class_attribute :ai_prompt_template, instance_accessor: false
    end

    class_methods do
      def prompt_template(template = nil)
        return ai_prompt_template if template.nil?
        self.ai_prompt_template = template
      end

      # Load a template from the template registry
      def ai_use_template(name)
        template = RailsAIPromptable::TemplateRegistry.get(name)

        if template.nil?
          raise ArgumentError, "Template '#{name}' not found. Available templates: #{RailsAIPromptable::TemplateRegistry.list.join(', ')}"
        end

        self.ai_prompt_template = template
      end
    end

    def ai_generate(context: {}, model: nil, temperature: nil, format: :text)
      template = self.class.ai_prompt_template || ''
      prompt = render_template(template, context)

      RailsAIPromptable.configuration.logger.info("[rails_ai_promptable] prompt: ")

      response = RailsAIPromptable.client.generate(
        prompt: prompt,
        model: model || RailsAIPromptable.configuration.default_model,
        temperature: temperature || 0.7,
        format: format
      )

      # basic parsing
      response
    end

    def ai_generate_later(context: {}, **kwargs)
      RailsAIPromptable.configuration.logger.info('[rails_ai_promptable] enqueuing ai_generate_later')
      # Use ActiveJob to enqueue. We'll provide a default job class in later steps.
      RailsAIPromptable::BackgroundJob.perform_later(self.class.name, id, context, kwargs)
    end

    private

    def render_template(template, context)
      template % context.transform_keys(&:to_sym)
    rescue KeyError
      # fallback: simple interpolation using gsub
      result = template.dup
      context.each { |k, v| result.gsub!("%{#{k}}", v.to_s) }
      result
    end
  end
end
