# frozen_string_literal: true

module Uchi
  module Ui
    class PageHeader < ViewComponent::Base
      attr_reader :description, :title

      renders_many :actions

      def initialize(title:, description: nil)
        super()
        @description = description
        @title = title
      end
    end
  end
end
