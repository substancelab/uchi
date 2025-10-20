# frozen_string_literal: true

module Flowbite
  class BreadcrumbItem
    # Renders the first breadcrumb item (typically home).
    # First items don't show a separator icon.
    #
    # @param href [String] The URL for the breadcrumb link.
    # @param options [Hash] Additional HTML attributes to pass to the link element.
    #
    # @example First item
    #   <%= render Flowbite::BreadcrumbItem::First.new(href: "/") { "Home" } %>
    class First < BreadcrumbItem
      protected

      def item_options
        {class: "inline-flex items-center"}
      end

      def link_classes
        ["text-sm", "font-medium", "inline-flex", "items-center", "text-gray-700", "hover:text-blue-600", "dark:text-gray-400", "dark:hover:text-white"]
      end

      def prefix_icon
        Flowbite::BreadcrumbHome.new
      end
    end
  end
end
