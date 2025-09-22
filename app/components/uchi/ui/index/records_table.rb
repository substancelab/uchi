# frozen_string_literal: true

module Uchi
  module Ui
    module Index
      class RecordsTable < ViewComponent::Base
        # Returns the columns to be displayed in this table. Each column is a
        # representation of a Field from repository. Defaults to all fields.
        attr_reader :columns

        attr_reader :sort_order, :records, :repository, :scope

        def initialize(columns:, records:, repository:, scope: nil, sort_order: nil)
          super()
          @columns = columns
          @sort_order = sort_order
          @records = records
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
              scope[:field],
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
