# frozen_string_literal: true

module Uchi
  module Ui
    class Breadcrumbs < ViewComponent::Base
      attr_reader :items

      def initialize(items:)
        super()
        @items = items
      end
    end
  end
end
