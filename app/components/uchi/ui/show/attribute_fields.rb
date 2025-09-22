# frozen_string_literal: true

module Uchi
  module Ui
    module Show
      class AttributeFields < ViewComponent::Base
        attr_reader :attribute_fields, :record, :repository

        def initialize(attribute_fields:, record:, repository:)
          super()
          @attribute_fields = attribute_fields
          @record = record
          @repository = repository
        end
      end
    end
  end
end
