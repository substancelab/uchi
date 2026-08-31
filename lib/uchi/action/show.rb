# frozen_string_literal: true

require_relative "../action"

module Uchi
  class Action
    # Redirects to the show page for a record.
    class Show < Action
      def perform(records, input = {})
        # Theoretically, this action should never use it's #perform method since
        # it renders a link directly to the show page without even executing the
        # action.
        record = records.first

        Uchi::ActionResponse.success.redirect_to(
          path: repository.routes.path_for(:show, id: record.id)
        )
      end

      # Renders as a plain link to the show page, instead of a button that
      # executes the action via a POST request.
      def render(record:, repository:, view:)
        view.link_to(
          name,
          repository.routes.path_for(:show, id: record.id),
          class: "block p-2 hover:bg-neutral-tertiary-medium hover:text-heading rounded",
          data: {
            "turbo-frame": "_top"
          }
        )
      end

      # Renders as an icon-only link to the show page, for use in a records
      # table row.
      def row_render(record:, repository:, view:)
        view.link_to(
          repository.routes.path_for(:show, id: record.id),
          class: icon_classes,
          data: {
            "turbo-frame": "_top"
          }
        ) do
          icon(view)
        end
      end

      def icon(view)
        # eye icon from Flowbite Icons
        view.tag.svg(
          "aria-hidden": "true",
          class: "w-6 h-6",
          fill: "none",
          height: "24",
          viewBox: "0 0 24 24",
          width: "24",
          xmlns: "http://www.w3.org/2000/svg"
        ) do
          view.safe_join([
            view.tag.path(
              d: "M21 12c0 1.2-4.03 6-9 6s-9-4.8-9-6c0-1.2 4.03-6 9-6s9 4.8 9 6Z",
              stroke: "currentColor",
              "stroke-width": "2"
            ),
            view.tag.path(
              d: "M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z",
              stroke: "currentColor",
              "stroke-width": "2"
            )
          ])
        end
      end

      protected

      def default_on
        [:row]
      end
    end
  end
end
