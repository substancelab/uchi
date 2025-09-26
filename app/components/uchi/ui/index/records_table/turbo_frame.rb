# frozen_string_literal: true

module Uchi
  module Ui
    module Index
      class RecordsTable
        class TurboFrame < ViewComponent::Base
          attr_reader :repository, :scope

          def initialize(repository:, scope: nil)
            super()
            @repository = repository
            @scope = scope
          end

          protected

          def scoped?
            scope.present?
          end

          def turbo_frame_id
            parts = if scoped?
              [
                scope[:model],
                scope[:id],
                scope[:field]
              ]
            else
              [repository.controller_name]
            end
            parts.compact.join("_")
          end
        end
      end
    end
  end
end
