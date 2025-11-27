# frozen_string_literal: true

module Uchi
  module Ui
    module Actions
      # Renders a dropdown menu of actions that can be performed on a record.
      #
      # This component displays available actions for a repository in a dropdown
      # menu. Each action can be clicked to execute it on the specified record(s).
      class Dropdown < ViewComponent::Base
        attr_reader :actions, :record, :repository

        def initialize(actions:, record:, repository:)
          super()
          @actions = actions
          @record = record
          @repository = repository
        end

        def render?
          actions.any?
        end
      end
    end
  end
end
