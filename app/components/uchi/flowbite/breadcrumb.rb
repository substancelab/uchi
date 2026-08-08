# frozen_string_literal: true

module Uchi::Flowbite
  # Renders a breadcrumb navigation component.
  #
  # Use {Uchi::Flowbite::Breadcrumb} and the child {Uchi::Flowbite::Breadcrumb::Item}
  # components to create and indicate a series of page structure and URLs to
  # help the user navigate through the website.
  #
  # Breadcrumbs consist of the following components:
  #
  # - {Uchi::Flowbite::Breadcrumb}: Container for breadcrumb items.
  # - {Uchi::Flowbite::Breadcrumb::HomeIcon}: Home icon for the first breadcrumb item.
  # - {Uchi::Flowbite::Breadcrumb::SeparatorIcon}: Separator between breadcrumb items.
  # - {Uchi::Flowbite::Breadcrumb::Item}: An individual breadcrumb item.
  # - {Uchi::Flowbite::Breadcrumb::Item::Current}: An individual breadcrumb item
  #   without a link, usually used for the current page in the breadcrumb trail.
  # - {Uchi::Flowbite::Breadcrumb::Item::First}: An individual breadcrumb item with a
  #   home icon on it.
  #
  # @example Usage
  #   <%= render(Uchi::Flowbite::Breadcrumb.new) do |breadcrumb| %>
  #     <% breadcrumb.with_item do %>
  #       <%= render(Uchi::Flowbite::Breadcrumb::Item::First.new(href: "/")) { "Root page" } %>
  #     <% end %>
  #     <% breadcrumb.with_item do %>
  #       <%= render(Uchi::Flowbite::Breadcrumb::Item.new(href: "/projects")) { "Parent page" } %>
  #     <% end %>
  #     <% breadcrumb.with_item do %>
  #       <%= render(Uchi::Flowbite::Breadcrumb::Item::Current.new) { "Current Page" } %>
  #     <% end %>
  #   <% end %>
  #
  # @viewcomponent_slot [Uchi::Flowbite::Breadcrumb::Item] items The items of the
  #   breadcrumb trail. Use {Uchi::Flowbite::Breadcrumb::Item::First} for the first
  #   item to get a home icon, and {Uchi::Flowbite::Breadcrumb::Item::Current} for the
  #   last item to render it without a link.
  #
  # @lookbook_embed BreadcrumbPreview
  # @see https://flowbite.com/docs/components/breadcrumb/
  class Breadcrumb < ViewComponent::Base
    renders_many :items

    def call
      content_tag(:nav, class: "flex", "aria-label": "Breadcrumb") do
        content_tag(:ol, class: "inline-flex items-center space-x-1 md:space-x-2 rtl:space-x-reverse") do
          items.each do |item|
            concat(item)
          end
        end
      end
    end
  end
end
