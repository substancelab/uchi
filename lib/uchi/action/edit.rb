# frozen_string_literal: true

require_relative "../action"

module Uchi
  class Action
    # Redirects to the edit page for a record.
    class Edit < Action
      def perform(records, input = {})
        # Theoretically, this action should never use it's #perform method since
        # it renders a link directly to the edit page without even executing the
        # action.
        record = records.first

        Uchi::ActionResponse.success.redirect_to(
          path: repository.routes.path_for(:edit, id: record.id)
        )
      end

      # Renders as a plain link to the edit page, instead of a button that
      # executes the action via a POST request.
      def render(record:, repository:, view:)
        view.link_to(
          name,
          repository.routes.path_for(:edit, id: record.id),
          class: "block p-2 hover:bg-neutral-tertiary-medium hover:text-heading rounded",
          data: {
            "turbo-frame": "_top"
          }
        )
      end

      # Renders as an icon-only link to the edit page, for use in a records
      # table row.
      def index_render(record:, repository:, view:)
        view.link_to(
          repository.routes.path_for(:edit, id: record.id),
          class: icon_classes,
          data: {
            "turbo-frame": "_top"
          }
        ) do
          icon(view)
        end
      end

      def icon(view)
        # pen-to-square icon from Flowbite Icons
        view.tag.svg(
          "aria-hidden": "true",
          class: "w-6 h-6",
          fill: "none",
          height: "24",
          viewBox: "0 0 24 24",
          width: "24",
          xmlns: "http://www.w3.org/2000/svg"
        ) do
          view.tag.path(
            d: "m14.304 4.844 2.852 2.852M7 7H4a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h11a1 1 0 0 0 1-1v-4.5m2.409-9.91a2.017 2.017 0 0 1 0 2.853l-6.844 6.844L8 14l.713-3.565 6.844-6.844a2.015 2.015 0 0 1 2.852 0Z",
            stroke: "currentColor",
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2"
          )
        end
      end
    end
  end
end
