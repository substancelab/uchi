module Uchi
  module Ui
    module Index
      class RecordsTable
        # Renders a search for the records table.
        #
        # Based on Flowbites Simple search input
        # (https://flowbite.com/docs/forms/search-input/#simple-search-input)
        class SearchForm < ViewComponent::Base
          attr_reader :params, :repository

          def initialize(params:, repository:)
            super()
            @params = params
            @repository = repository
          end

          def query
            params[:query]
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
