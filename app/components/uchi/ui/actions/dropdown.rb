# frozen_string_literal: true

module Uchi
  module Ui
    module Actions
      # Renders a dropdown menu of actions that can be performed on a record.
      #
      # This component displays available actions for a repository. Each action
      # can be clicked to execute it on the specified record(s). The first
      # Repository#max_number_of_actions_outside_dropdown actions are rendered
      # directly as buttons; any remaining actions are placed in a dropdown menu.
      class Dropdown < ViewComponent::Base
        include Uchi::RoutesHelper

        attr_reader :actions, :record, :repository

        def initialize(actions:, repository:, record: nil)
          super()
          @actions = actions
          @record = record
          @repository = repository

          actions.each { |action| action.repository = repository }
        end

        def render?
          actions.any?
        end

        private

        def actions_inside_dropdown
          @actions_inside_dropdown ||= actions.drop(max_number_of_actions_outside_dropdown)
        end

        def actions_outside_dropdown
          @actions_outside_dropdown ||= actions.first(max_number_of_actions_outside_dropdown)
        end

        def button_id
          "actions-dropdown-button-#{record_id}"
        end

        def dropdown_id
          "actions-dropdown-#{record_id}"
        end

        def max_number_of_actions_outside_dropdown
          repository&.max_number_of_actions_outside_dropdown || 1
        end

        def record_id
          @record_id ||= record&.id || object_id
        end
      end
    end
  end
end
