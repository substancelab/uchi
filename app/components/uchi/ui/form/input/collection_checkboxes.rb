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
            base = ["select-none ms-2 text-sm font-medium"]
            if disabled?
              base + ["text-fg-disabled"]
            elsif errors?
              base + ["text-fg-danger-strong"]
            else
              base + ["text-heading"]
            end
          end

          def hint_classes
            base = ["text-xs", "font-normal", "mt-1"]
            if disabled?
              base + ["text-fg-disabled"]
            else
              base + ["text-body"]
            end
          end

          def checkbox_item_classes
            ["flex", "items-start", "mb-3"]
          end

          def checkbox_classes
            base = ["w-4", "h-4", "border", "rounded-xs", "focus:ring-2"]
            if disabled?
              base + ["border-light", "bg-neutral-secondary-medium", "focus:ring-brand-soft"]
            elsif errors?
              base + ["text-fg-danger", "bg-danger-soft", "border-fg-danger", "focus:ring-fg-danger"]
            else
              base + ["border-default-medium", "bg-neutral-secondary-medium", "focus:ring-brand-soft"]
            end
          end

          def checkbox_label_classes
            if disabled?
              ["select-none", "ms-2", "text-sm", "font-medium", "text-fg-disabled"]
            else
              ["select-none", "ms-2", "text-sm", "font-medium", "text-heading"]
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
