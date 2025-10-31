# frozen_string_literal: true

module Flowbite
  module Input
    # The checkbox component can be used to receive one or more selected options
    # from the user in the form of a square box available in multiple styles,
    # sizes, colors, and variants coded with the utility classes from Tailwind
    # CSS and with support for dark mode.
    #
    # https://flowbite.com/docs/forms/checkbox/
    class Checkbox < Field
      DEFAULT_CHECKED_VALUE = "1"
      DEFAULT_UNCHECKED_VALUE = "0"

      class << self
        # Checkboxes only have their default size.
        def sizes
          {
            default: ["w-4", "h-4"]
          }
        end

        # rubocop:disable Layout/LineLength
        def styles
          {
            default: Flowbite::Style.new(
              default: ["text-blue-600", "bg-gray-100", "border-gray-300", "rounded-sm", "focus:ring-blue-500", "dark:focus:ring-blue-600", "dark:ring-offset-gray-800", "focus:ring-2", "dark:bg-gray-700", "dark:border-gray-600"],
              disabled: ["text-blue-600", "bg-gray-100", "border-gray-300", "rounded-sm", "focus:ring-blue-500", "dark:focus:ring-blue-600", "dark:ring-offset-gray-800", "focus:ring-2", "dark:bg-gray-700", "dark:border-gray-600"],
              error: ["text-red-600", "bg-red-50", "border-red-500", "rounded-sm", "focus:ring-red-500", "dark:focus:ring-red-600", "dark:ring-offset-gray-800", "focus:ring-2", "dark:bg-gray-700", "dark:border-red-500"]
            )
          }.freeze
        end
      end

      # Returns the HTML to use for the actual input field element.
      def call
        @form.send(
          input_field_type,
          @attribute,
          input_options,
          checked_value,
          unchecked_value
        )
      end

      def initialize(attribute:, form:, disabled: false, options: {}, size: :default, unchecked_value: DEFAULT_UNCHECKED_VALUE, value: DEFAULT_CHECKED_VALUE)
        super(attribute: attribute, form: form, disabled: disabled, options: options, size: size)
        @unchecked_value = unchecked_value
        @value = value
      end

      def input_field_type
        :check_box
      end

      # Returns the options argument for the input field
      def input_options
        {
          class: classes,
          disabled: disabled?
        }.merge(options)
      end

      private

      def checked_value
        @value
      end

      attr_reader :unchecked_value
    end
  end
end
