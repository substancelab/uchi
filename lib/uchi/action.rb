# frozen_string_literal: true

module Uchi
  # Base class for all Uchi actions.
  #
  # Actions allow you to perform custom operations on one or more records from
  # a repository. Examples include publishing posts, exporting data, or sending
  # notifications.
  #
  # To create an action, subclass this class and implement the `handle` method:
  #
  #   class PublishPost < Uchi::Action
  #     def handle(records, input = {})
  #       records.each { |record| record.update!(published: true) }
  #       ActionResponse.success("Published #{records.size} posts")
  #     end
  #   end
  #
  # Actions are registered on repositories via the `actions` method:
  #
  #   class PostRepository < Uchi::Repository
  #     def actions
  #       [PublishPost.new]
  #     end
  #   end
  class Action
    # Returns the icon name for this action (optional).
    #
    # The icon should be a Heroicons icon name (e.g., "check-circle").
    #
    # @return [String, nil]
    def icon
      nil
    end

    # Returns the display name for this action.
    #
    # By default, this looks up the translation key
    # `uchi.action.[action_key].name` and falls back to the humanized class
    # name.
    #
    # @return [String]
    def name
      translate(:name, default: self.class.name.demodulize.titleize)
    end

    # Returns the list of fields to show in the action form.
    #
    # Fields are instances of Uchi::Field subclasses (e.g., Field::String,
    # Field::Boolean).
    #
    # @return [Array<Uchi::Field>]
    def fields
      []
    end

    # Executes the action on the given records.
    #
    # This method must be implemented in subclasses.
    #
    # @param records [ActiveRecord::Relation, Array] - The records to operate on
    # @param input [Hash] - Hash of field values from the action form
    # @return [Uchi::ActionResponse]
    def handle(records, input = {})
      raise NotImplementedError, "#{self.class}#handle must be implemented"
    end

    # Returns true if this action requires input fields.
    #
    # @return [Boolean]
    def requires_input?
      fields.any?
    end

    private

    # Looks up i18n key with fallback
    # @param key [Symbol] - the key to look up (e.g., :name, :confirm_text)
    # @param default [String] - fallback value
    # @param options [Hash] - additional i18n options (count, etc.)
    # @return [String, nil]
    def translate(key, default:, **options)
      i18n_key = "action.#{translation_key}.#{key}"
      Uchi::I18n.translate(i18n_key, default: default, **options)
    end

    # Returns the i18n key segment for this action
    # Example: PublishPost -> "publish_post"
    def translation_key
      self.class.name.underscore.tr("/", ".")
    end
  end
end
