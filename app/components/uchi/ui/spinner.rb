# frozen_string_literal: true

module Uchi
  module Ui
    # https://flowbite.com/docs/components/spinner/
    class Spinner < ViewComponent::Base
      attr_reader :message

      def initialize(message: "Loading...")
        super()
        @message = message
      end
    end
  end
end
