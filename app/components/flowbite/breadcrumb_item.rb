# frozen_string_literal: true

module Flowbite
  # Base class for rendering a breadcrumb item (middle items in the breadcrumb trail).
  #
  # @param href [String] The URL for the breadcrumb link.
  # @param options [Hash] Additional HTML attributes to pass to the link element.
  #
  # @example Middle item
  #   <%= render Flowbite::BreadcrumbItem.new(href: "/projects") { "Projects" } %>
  class BreadcrumbItem < ViewComponent::Base
    attr_reader :href, :options

    def initialize(href:, **options)
      super()
      @href = href
      @options = options
    end

    def call
      content_tag(:li, item_options) do
        content_tag(:div, class: "flex items-center") do
          concat(separator_icon)
          concat(render_link)
        end
      end
    end

    protected

    def item_options
      {}
    end

    def render_link
      link_options = {class: link_classes}.merge(options)
      content_tag(:a, content, href: href, **link_options)
    end

    def link_classes
      ["text-sm", "font-medium", "ms-1", "text-gray-700", "hover:text-blue-600", "md:ms-2", "dark:text-gray-400", "dark:hover:text-white"]
    end

    def separator_icon
      tag.svg(
        class: "rtl:rotate-180 w-3 h-3 text-gray-400 mx-1",
        "aria-hidden": "true",
        xmlns: "http://www.w3.org/2000/svg",
        fill: "none",
        viewBox: "0 0 6 10"
      ) do
        tag.path(
          stroke: "currentColor",
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          "stroke-width": "2",
          d: "m1 9 4-4-4-4"
        )
      end
    end
  end
end
