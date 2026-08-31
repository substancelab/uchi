# frozen_string_literal: true

require_relative "../action"

module Uchi
  class Action
    # Destroys the given records.
    class Delete < Action
      def perform(records, input = {})
        destroyed = records.map { |record| record.destroy }

        if destroyed.all?
          Uchi::ActionResponse.success
        else
          Uchi::ActionResponse.error
        end
      end

      def style
        :danger
      end

      def render(record:, repository:, view:)
        view.button_to(
          repository.translate.link_to_destroy(record),
          repository.routes.path_for(:destroy, id: record.id),
          class: "block p-2 rounded text-left w-full hover:bg-neutral-tertiary-medium hover:text-heading",
          data: {
            "turbo-confirm": repository.translate.destroy_dialog_title(record)
          },
          method: :delete
        )
      end

      def row_render(record:, repository:, view:)
        view.button_to(
          icon(view),
          repository.routes.path_for(:destroy, id: record.id),
          class: icon_classes,
          data: {
            "turbo-confirm": repository.translate.destroy_dialog_title(record)
          },
          method: :delete
        )
      end

      def icon(view)
        # trash-bin icon from Flowbite Icons
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
            d: "M5 7h14m-9 3v8m4-8v8M10 3h4a1 1 0 0 1 1 1v3H9V4a1 1 0 0 1 1-1ZM6 7h12v13a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V7Z",
            stroke: "currentColor",
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2"
          )
        end
      end

      protected

      def default_on
        [:row]
      end
    end
  end
end
