module Uchi
  # Encapsulates the sort order selected by a user.
  class SortOrder
    attr_reader :column, :direction

    class << self
      def from_params(params)
        sort_params = params[:sort] || {}
        return nil if sort_params.empty?

        by = sort_params[:by]
        return by unless by

        direction = sort_params[:direction] || :asc
        new(by, direction)
      end
    end

    def ascending?
      direction == :asc
    end

    def apply(query)
      if column.respond_to?(:asc)
        query.order(ascending? ? column.asc : column.desc)
      else
        query.order(column => direction)
      end
    end

    def descending?
      direction == :desc
    end

    def initialize(column, direction)
      @column = column.respond_to?(:asc) ? column : column.to_sym
      @direction = direction.to_sym
    end
  end
end
