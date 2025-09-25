# frozen_string_literal: true

module Uchi
  class Repository
    class Translate
      attr_reader :repository

      # Returns a description for the given page, or nil if none is found.
      # This description is intended to provide additional context for the page
      # being shown.
      def description(page, record: nil)
        translate(
          "description",
          default: nil,
          model: singular_name,
          record: record,
          scope: i18n_scope(page)
        )
      end

      def initialize(repository:)
        @repository = repository
      end

      # Returns the label for the given field.
      def field_label(field)
        translate(
          "label",
          default: model.human_attribute_name(field.name),
          scope: i18n_scope("field.#{field.name}")
        )
      end

      # Returns the hint for the given field, or nil if none is found.
      def field_hint(field)
        translate(
          "hint",
          default: nil,
          scope: i18n_scope("field.#{field.name}")
        )
      end

      def link_to_cancel
        translate("common.cancel", default: "Cancel")
      end

      def link_to_edit(record)
        translate(
          "link_to_edit",
          default: "Edit",
          model: singular_name,
          record: repository.title(record),
          scope: i18n_scope("button")
        )
      end

      # Returns the text for the "new" action link.
      def link_to_new
        translate(
          "link_to_new",
          default: "New %{model}", # rubocop:disable Style/FormatStringToken
          model: singular_name,
          scope: i18n_scope("button")
        )
      end

      # Returns the localized, human-readable plural name of the model this
      # repository manages.
      def plural_name
        ::I18n.translate(
          "uchi.repository.#{i18n_key}.model",
          count: 2,
          default: model.model_name.plural.humanize
        )
      end

      # Returns the label for a generic submit button
      def submit_button
        translate("common.save", default: "Save")
      end

      # Returns the title for the given page.
      def title(page, record: nil)
        return repository.title(record) if record && page == :show

        translate(
          "title",
          default: plural_name,
          model: singular_name,
          record: record,
          scope: i18n_scope(page)
        )
      end

      private

      # Returns the segment of the i18n key specific to this repository.
      def i18n_key
        @repository.model.model_name.i18n_key
      end

      def i18n_scope(section)
        "uchi.repository.#{i18n_key}.#{section}"
      end

      def model
        @model ||= repository.model
      end

      # Returns the localized, human-readable singular name of the model this
      # repository manages.
      def singular_name
        ::I18n.translate(
          "uchi.repository.#{i18n_key}.model",
          count: 1,
          default: model.model_name.human(count: 1)
        )
      end

      def translate(key, **options)
        Uchi::I18n.translate(key, **options)
      end
    end
  end
end
