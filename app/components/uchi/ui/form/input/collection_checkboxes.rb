# frozen_string_literal: true

module Uchi
  module Ui
    module Form
      module Input
        # A component that wraps Rails' collection_check_boxes form helper
        # to render multiple checkboxes from a collection using Flowbite styling.
        #
        # Example usage:
        #   <%= render Uchi::Ui::Form::Input::CollectionCheckboxes.new(
        #     attribute: :tag_ids,
        #     collection: @tags,
        #     form: form,
        #     label: "Select Tags",
        #     value_method: :id,
        #     text_method: :name
        #   ) %>
        class CollectionCheckboxes < ViewComponent::Base
          attr_reader :attribute, :collection, :form, :label_text, :hint_text,
            :value_method, :text_method, :disabled

          def initialize(
            attribute:,
            collection:,
            form:,
            label: nil,
            hint: nil,
            value_method: :id,
            text_method: :name,
            disabled: false,
            options: {}
          )
            super()
            @attribute = attribute
            @collection = collection
            @form = form
            @label_text = label
            @hint_text = hint
            @value_method = value_method
            @text_method = text_method
            @disabled = disabled
            @options = options || {}
          end

          def object
            @object ||= form.object
          end

          def errors
            @errors ||= object.errors[attribute] || []
          end

          def errors?
            errors.any?
          end

          def disabled?
            !!disabled
          end

          def render_label?
            label_text.present?
          end

          def render_hint?
            hint_text.present?
          end

          def label_classes
            base = ["block", "mb-2", "text-sm", "font-medium"]
            if disabled?
              base + ["text-gray-400", "dark:text-gray-500"]
            elsif errors?
              base + ["text-red-700", "dark:text-red-500"]
            else
              base + ["text-gray-900", "dark:text-white"]
            end
          end

          def hint_classes
            base = ["text-xs", "font-normal", "mt-1"]
            if disabled?
              base + ["text-gray-400", "dark:text-gray-500"]
            else
              base + ["text-gray-500", "dark:text-gray-300"]
            end
          end

          def checkbox_item_classes
            ["flex", "items-start", "mb-3"]
          end

          def checkbox_classes
            base = ["w-4", "h-4", "rounded-sm", "focus:ring-2", "focus:ring-offset-2"]
            if disabled?
              base + ["text-blue-600", "bg-gray-100", "border-gray-300",
                "dark:bg-gray-700", "dark:border-gray-600"]
            elsif errors?
              base + ["text-red-600", "bg-red-50", "border-red-500",
                "focus:ring-red-500", "dark:focus:ring-red-600",
                "dark:bg-gray-700", "dark:border-red-500"]
            else
              base + ["text-blue-600", "bg-gray-100", "border-gray-300",
                "focus:ring-blue-500", "dark:focus:ring-blue-600",
                "dark:bg-gray-700", "dark:border-gray-600"]
            end
          end

          def checkbox_label_classes
            if disabled?
              ["ms-2", "text-sm", "font-medium", "text-gray-400", "dark:text-gray-500"]
            else
              ["ms-2", "text-sm", "font-medium", "text-gray-900", "dark:text-gray-300"]
            end
          end

          def collection_check_boxes_options
            @options
          end
        end
      end
    end
  end
end
