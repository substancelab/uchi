# frozen_string_literal: true

require_relative "../action"

module Uchi
  class Action
    # Redirects to the new-record page.
    class New < Action
      def perform(records, input = {})
        # Theoretically, this action should never use it's #perform method since
        # it renders a link directly to the new-record page without executing
        # the action.
        Uchi::ActionResponse.success.redirect_to(
          path: repository.routes.path_for(:new)
        )
      end

      # Renders as a plain link to the new-record page, instead of a button
      # that executes the action via a POST request.
      def render(record:, repository:, view:)
        view.link_to(
          repository.translate.link_to_new,
          repository.routes.path_for(:new),
          class: "block p-2 hover:bg-neutral-tertiary-medium hover:text-heading rounded",
          data: {
            "turbo-frame": "_top"
          }
        )
      end

      # Renders as a primary button-styled link to the new-record page, for
      # use when this is the only action available.
      def button_render(record:, repository:, view:)
        view.link_to(
          repository.translate.link_to_new,
          repository.routes.path_for(:new),
          class: Uchi::Flowbite::Button.classes(style: style),
          data: {
            "turbo-frame": "_top"
          }
        )
      end

      protected

      def default_on
        [:index]
      end
    end
  end
end
