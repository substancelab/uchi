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
      def classes
        ["flex", "items-center", "w-full", "max-w-xs", "p-4", "text-gray-500", "bg-white", "rounded-lg", "shadow-sm", "dark:text-gray-400", "dark:bg-gray-800"]
      end
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
      self.class.classes + additional_classes
    end
  end
end
