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

      def input_field_type
        :check_box
      end
    end
  end
end
