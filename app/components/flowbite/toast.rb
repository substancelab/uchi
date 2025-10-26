# frozen_string_literal: true

module Flowbite
  # Renders a toast notification element.
  #
  # See https://flowbite.com/docs/components/toast/
  #
  # @param message [String] The message to display in the toast.
  # @param style [Symbol] The color style of the toast (:default, :success, :danger, :warning).
  # @param dismissible [Boolean] Whether the toast can be dismissed (default: true).
  # @param class [Array<String>] Additional CSS classes for the toast container.
  # @param options [Hash] Additional HTML options for the toast container.
  class Toast < ViewComponent::Base
    class << self
      def classes(style: :default)
        base_classes + style_classes(style)
      end

      def icon_classes(style: :default)
        styles.fetch(style).fetch(:icon)
      end

      def icon_svg_path(style: :default)
        styles.fetch(style).fetch(:svg_path)
      end

      private

      def base_classes
        ["flex", "items-center", "w-full", "max-w-xs", "p-4", "text-gray-500", "bg-white", "rounded-lg", "shadow-sm", "dark:text-gray-400", "dark:bg-gray-800"]
      end

      def style_classes(style)
        styles.fetch(style).fetch(:container)
      end

      # rubocop:disable Layout/LineLength
      def styles
        {
          default: {
            container: [],
            icon: ["inline-flex", "items-center", "justify-center", "shrink-0", "w-8", "h-8", "text-blue-500", "bg-blue-100", "rounded-lg", "dark:bg-blue-800", "dark:text-blue-200"],
            svg_path: "M15.147 15.085a7.159 7.159 0 0 1-6.189 3.307A6.713 6.713 0 0 1 3.1 15.444c-2.679-4.513.287-8.737.888-9.548A4.373 4.373 0 0 0 5 1.608c1.287.953 6.445 3.218 5.537 10.5 1.5-1.122 2.706-3.01 2.853-6.14 1.433 1.049 3.993 5.395 1.757 9.117Z"
          },
          success: {
            container: [],
            icon: ["inline-flex", "items-center", "justify-center", "shrink-0", "w-8", "h-8", "text-green-500", "bg-green-100", "rounded-lg", "dark:bg-green-800", "dark:text-green-200"],
            svg_path: "M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z"
          },
          danger: {
            container: [],
            icon: ["inline-flex", "items-center", "justify-center", "shrink-0", "w-8", "h-8", "text-red-500", "bg-red-100", "rounded-lg", "dark:bg-red-800", "dark:text-red-200"],
            svg_path: "M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 11.793a1 1 0 1 1-1.414 1.414L10 11.414l-2.293 2.293a1 1 0 0 1-1.414-1.414L8.586 10 6.293 7.707a1 1 0 0 1 1.414-1.414L10 8.586l2.293-2.293a1 1 0 0 1 1.414 1.414L11.414 10l2.293 2.293Z"
          },
          warning: {
            container: [],
            icon: ["inline-flex", "items-center", "justify-center", "shrink-0", "w-8", "h-8", "text-orange-500", "bg-orange-100", "rounded-lg", "dark:bg-orange-700", "dark:text-orange-200"],
            svg_path: "M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5ZM10 15a1 1 0 1 1 0-2 1 1 0 0 1 0 2Zm1-4a1 1 0 0 1-2 0V6a1 1 0 0 1 2 0v5Z"
          }
        }.freeze
      end
      # rubocop:enable Layout/LineLength
    end

    attr_reader :message, :style, :dismissible, :additional_classes, :options

    def initialize(message:, style: :default, dismissible: true, class: [], **options)
      @message = message
      @style = style
      @dismissible = dismissible
      @additional_classes = Array(binding.local_variable_get(:class)) || []
      @options = options
    end

    def container_classes
      self.class.classes(style: style) + additional_classes
    end

    def icon_container_classes
      self.class.icon_classes(style: style)
    end

    def svg_path
      self.class.icon_svg_path(style: style)
    end
  end
end
