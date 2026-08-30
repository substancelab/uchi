# frozen_string_literal: true

module Uchi
  module Ui
    module Index
      class RecordsTable < ViewComponent::Base
        # Returns the columns to be displayed in this table. Each column is a
        # representation of a Field from repository. Defaults to all fields.
        attr_reader :columns

        attr_reader :edit_action, :query, :sort_order, :records, :repository, :scope

        def initialize(columns:, records:, repository:, edit_action: Uchi::Action::Edit.new, query: nil, scope: nil, sort_order: nil)
          super()
          @columns = columns
          @edit_action = edit_action
          @query = query
          @sort_order = sort_order
          @records = records
          @repository = repository
          @scope = scope
        end
      end
    end
  end
end
