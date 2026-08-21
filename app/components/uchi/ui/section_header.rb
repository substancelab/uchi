# frozen_string_literal: true

module Uchi
  module Ui
    class SectionHeader < ViewComponent::Base
      attr_reader :title

      renders_many :actions

      def initialize(title:)
        super()
        @title = title
      end
    end
  end
end
