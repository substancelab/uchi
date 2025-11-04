# frozen_string_literal: true

module Uchi
  class Repository
    class Translate
      attr_reader :repository

      # Returns the breadcrumb label for the given page.
      #
      # Example translation key:
      #   uchi.repository.author.breadcrumb.edit.label
      def breadcrumb_label(page, record: nil)
        return breadcrumb_label_for_index if page.to_sym == :index

        default = {
          show: title_for_record(record)
        }[page.to_sym].presence
        default ||= translate("common.#{page}", default: page.to_s.capitalize)

        translate(
          "label",
          default: default,
          model: singular_name,
          record: title_for_record(record),
          scope: i18n_scope("breadcrumb.#{page}")
        )
      end

      # Returns the breadcrumb label for the index page.
      #
      # Returns the first of the following that is present:
      # 1. Translation from "uchi.repository.author.breadcrumb.index.label"
      # 2. Translation from "uchi.repository.author.index.title"
      # 3. plural name of the model
      # 4. Translation from "common.index"
      # 5. Capitalized page name ("Index")
      def breadcrumb_label_for_index
        first_present_value(
          translate(i18n_scope("breadcrumb.index.label"), default: nil),
          translate(i18n_scope("index.title"), default: nil),
          plural_name,
          translate("common.index"),
          "Index"
        )
      end

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

      # Returns a title for a dialog with the given name, e.g. :destroy.
      # The title may include interpolation keys such as %{record}.
      #
      # Example translation key:
      #   uchi.repository.author.dialog.destroy.title
      #
      # Example default value:
      #   Are you sure you want to delete %{record}?
      #
      # Note that the default value itself is also looked up in the "common"
      # scope, so that it can be shared across repositories.
      #
      # Example fallback translation key:
      #   common.dialog.destroy.title
      #
      # Example fallback default value:
      #   Are you sure you want to delete this record?
      def destroy_dialog_title(record = nil)
        translate(
          "dialog.destroy.title",
          default: translate(
            "common.dialog.destroy.title",
            default: "Are you sure?",
            record: repository.title(record)
          ),
          record: repository.title(record),
          scope: "uchi.repository.#{i18n_key}"
        )
      end

      def failed_destroy
        translate(
          "destroy.failure",
          default: translate(
            "destroy.failure",
            default: "The record could not be deleted",
            scope: "common"
          ),
          scope: "uchi.repository.#{i18n_key}"
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

      def link_to_destroy(record)
        translate(
          "link_to_destroy",
          default: "Delete",
          model: singular_name,
          record: repository.title(record),
          scope: i18n_scope("button")
        )
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

      def loading_message
        translate("loading", default: "Loading...", scope: "uchi.repository.common")
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

      def no_records_found
        translate("no_records_found", default: "No records found", scope: "uchi.common")
      end

      def search_label
        translate("common.search", default: "Search")
      end

      def search_button
        translate("common.search", default: "Search")
      end

      # Returns the label for a generic submit button
      def submit_button
        translate("common.save", default: "Save")
      end

      def successful_create
        translate(
          "create.success",
          default: translate(
            "create.success",
            default: "Your changes have been saved",
            scope: "common"
          ),
          scope: "uchi.repository.#{i18n_key}"
        )
      end

      def successful_destroy
        translate(
          "destroy.success",
          default: translate(
            "destroy.success",
            default: "The record has been deleted",
            scope: "common"
          ),
          scope: "uchi.repository.#{i18n_key}"
        )
      end

      def successful_update
        translate(
          "update.success",
          default: translate(
            "update.success",
            default: "Your changes have been saved",
            scope: "common"
          ),
          scope: "uchi.repository.#{i18n_key}"
        )
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

      # Returns the first translation that yields a present value by looking
      # through each key in keys in order.
      def first_present_value(*values)
        values.find(&:presence)
      end

      # Returns the segment of the i18n key specific to this repository.
      def i18n_key
        @repository.model.model_name.i18n_key
      end

      def i18n_scope(section = nil)
        [
          "uchi.repository",
          i18n_key,
          section
        ].compact.join(".")
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

      def title_for_record(record)
        return nil unless record

        repository.title(record)
      end

      def translate(key, **options)
        Uchi::I18n.translate(key, **options)
      end
    end
  end
end
