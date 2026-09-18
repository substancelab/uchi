# frozen_string_literal: true

require_relative "../action"

module Uchi
  class Action
    # Redirects to the new page for a repository
    class New < Action
      def perform(records, input = {})
        # Theoretically, this action should never use its #perform method since
        # it renders a link directly to the new page without even executing the
        # action.
        Uchi::ActionResponse.success.redirect_to(
          path: repository.routes.path_for(:new)
        )
      end

      # Renders as a plain link to the new page, instead of a button that
      # executes the action via a POST request.
      def render_as_dropdown_item(record:, view:)
        view.link_to(
          name,
          repository.routes.path_for(:new),
          class: "block p-2 hover:bg-neutral-tertiary-medium hover:text-heading rounded"
        )
      end

      # Renders as a primary button-styled link to the new-record page, for
      # use when this is the only action available.
      def render_as_button(record:, view:)
        view.link_to(
          name,
          repository.routes.path_for(:new),
          class: Uchi::Flowbite::Button.classes(style: style),
          data: {
            "turbo-frame": "_top"
          }
        )
      end

      protected

      def default_on
        [Uchi::View::INDEX]
      end

      def name
        return super unless repository

        repository.translate.link_to_new
      end
    end
  end
end
