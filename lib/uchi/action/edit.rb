# frozen_string_literal: true

require_relative "../action"

module Uchi
  class Action
    # Redirects to the edit page for a record.
    class Edit < Action
      def perform(records, input = {})
        # Theoretically, this action should never use its #perform method since
        # it renders a link directly to the edit page without even executing the
        # action.
        record = records.first

        Uchi::ActionResponse.success.redirect_to(
          path: repository.routes.path_for(:edit, id: record.id)
        )
      end

      # Renders as a plain link to the edit page, instead of a button that
      # executes the action via a POST request.
      def render_as_dropdown_item(record:, view:)
        view.link_to(
          repository.translate.link_to_edit(record),
          repository.routes.path_for(:edit, id: record.id),
          class: "block p-2 hover:bg-neutral-tertiary-medium hover:text-heading rounded"
        )
      end

      # Renders a button to trigger the action, linking to the edit page, for
      # use when this is the only action available.
      def render_as_button(record:, view:)
        view.link_to(
          repository.translate.link_to_edit(record),
          repository.routes.path_for(:edit, id: record.id),
          class: Uchi::Flowbite::Button.classes(style: style),
          data: {
            "turbo-frame": "_top"
          }
        )
      end

      protected

      def default_on
        [Uchi::View::SHOW]
      end
    end
  end
end
