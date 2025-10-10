# frozen_string_literal: true

module Uchi
  module Ui
    module Index
      class RecordsTable < ViewComponent::Base
        # Returns the columns to be displayed in this table. Each column is a
        # representation of a Field from repository. Defaults to all fields.
        attr_reader :columns

        attr_reader :query, :sort_order, :records, :repository, :scope

        def initialize(columns:, records:, repository:, query: nil, scope: nil, sort_order: nil)
          super()
          @columns = columns
          @query = query
          @sort_order = sort_order
          @records = records
          @repository = repository
          @scope = scope
        end

        def path_for_edit(record)
          repository.routes.path_for(:edit, id: record.id, scope: scope)
        end
      end
    end
  end
end
