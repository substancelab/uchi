# frozen_string_literal: true

module Uchi
  module Ui
    module Form
      class Footer < ViewComponent::Base
        renders_many :actions

        def render?
          actions.any?
        end
      end
    end
  end
end
