# frozen_string_literal: true

module Flowbite
  # Renders a breadcrumb separator icon.
  #
  # This is automatically used by BreadcrumbItem components, but can be
  # used standalone if needed.
  #
  # @example Standalone usage
  #   <%= render Flowbite::BreadcrumbSeparator.new %>
  class BreadcrumbSeparator < ViewComponent::Base
    def call
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
