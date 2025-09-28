module Uchi
  module Ui
    module Index
      class RecordsTable
        class SearchForm < ViewComponent::Base
          attr_reader :params, :repository

          def initialize(params:, repository:)
            super()
            @params = params
            @repository = repository
          end

          def scope
            params[:scope]
          end

          def sort_by
            params.dig(:sort, :by)
          end

          def sort_by?
            sort_by.present?
          end

          def sort_direction
            params.dig(:sort, :direction)
          end

          def sort_direction?
            sort_direction.present?
          end
        end
      end
    end
  end
end
