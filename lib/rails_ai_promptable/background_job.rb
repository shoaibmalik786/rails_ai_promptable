# frozen_string_literal: true

begin
  require "active_job"
rescue LoadError
  # ActiveJob not available, skip loading BackgroundJob
end

if defined?(ActiveJob)
  module RailsAIPromptable
    class BackgroundJob < ActiveJob::Base
      queue_as :default

      def perform(klass_name, record_id, context, kwargs)
        klass = klass_name.constantize
        record = klass.find_by(id: record_id)
        return unless record

        result = record.ai_generate(context: context, **(kwargs || {}))

        # Call the callback method if defined on the record
        record.ai_generation_completed(result) if record.respond_to?(:ai_generation_completed)

        # Store result in ai_generated_content attribute if it exists
        if record.respond_to?(:ai_generated_content=)
          record.ai_generated_content = result
          record.save if record.respond_to?(:save)
        end

        RailsAIPromptable.configuration.logger.info("[rails_ai_promptable] background generation completed for #{klass_name}##{record_id}")

        result
      end
    end
  end
end
