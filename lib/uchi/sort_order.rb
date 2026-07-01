module Uchi
  class SortOrder
    attr_reader :attribute, :direction

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
      query.order(attribute => direction)
    end

    def descending?
      direction == :desc
    end

    def initialize(attribute, direction)
      @attribute = attribute.to_sym
      @direction = direction.to_sym
    end
  end
end
