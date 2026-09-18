# frozen_string_literal: true

require_relative "../action"

module Uchi
  class Action
    # Destroys the given records.
    class Delete < Action
      def perform(records, input = {})
        destroyed = records.map { |record| record.destroy }

        if destroyed.all?
          Uchi::ActionResponse.success(repository.translate.successful_destroy)
        else
          response = Uchi::ActionResponse.error(repository.translate.failed_destroy)
          response = response.redirect_to(path: repository.routes.path_for(:show, id: records.first.id)) if records.one?
          response
        end
      end

      # Renders as a button that submits a DELETE request directly to the
      # record's destroy route, with a confirmation dialog, instead of
      # executing the action via the generic actions execution endpoint.
      def render_as_dropdown_item(record:, view:)
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

      # Renders as a primary (danger-styled) button, for use when this is
      # the only action available.
      def render_as_button(record:, view:)
        view.button_to(
          repository.translate.link_to_destroy(record),
          repository.routes.path_for(:destroy, id: record.id),
          class: Uchi::Flowbite::Button.classes(style: style),
          data: {
            "turbo-confirm": repository.translate.destroy_dialog_title(record)
          },
          method: :delete
        )
      end

      def style
        :danger
      end

      protected

      def default_on
        [Uchi::View::EDIT]
      end
    end
  end
end
