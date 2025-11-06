# frozen_string_literal: true

require 'yaml'

module RailsAIPromptable
  class TemplateRegistry
    class << self
      def templates
        @templates ||= {}
      end

      # Register a template with a name
      def register(name, template)
        templates[name.to_sym] = template
      end

      # Get a template by name
      def get(name)
        templates[name.to_sym]
      end

      # Load templates from a YAML file
      def load_from_file(file_path)
        return unless File.exist?(file_path)

        begin
          loaded_templates = YAML.load_file(file_path)
          return unless loaded_templates.is_a?(Hash)

          loaded_templates.each do |name, template|
            register(name, template)
          end
        rescue Psych::SyntaxError => e
          # Log the error but don't raise - invalid YAML files are silently skipped
          if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
            Rails.logger.warn("[rails_ai_promptable] Failed to load templates from #{file_path}: #{e.message}")
          end
        end
      end

      # Load templates from a directory
      # Each file should be named <template_name>.yml or <template_name>.txt
      def load_from_directory(directory_path)
        return unless Dir.exist?(directory_path)

        Dir.glob(File.join(directory_path, '*')).each do |file_path|
          next unless File.file?(file_path)

          name = File.basename(file_path, '.*')

          if file_path.end_with?('.yml', '.yaml')
            content = YAML.load_file(file_path)
            template = content.is_a?(Hash) ? content['template'] : content.to_s
          else
            template = File.read(file_path)
          end

          register(name, template) if template
        end
      end

      # Clear all registered templates
      def clear!
        @templates = {}
      end

      # List all registered template names
      def list
        templates.keys
      end
    end
  end
end
