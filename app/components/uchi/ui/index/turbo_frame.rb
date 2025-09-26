# frozen_string_literal: true

module Uchi
  module Ui
    module Index
      class TurboFrame < ViewComponent::Base
        attr_reader :repository, :scope, :src

        def initialize(repository:, scope: nil, src: nil)
          super()
          @repository = repository
          @scope = scope
          @src = src
        end

        protected

        def options
          options = {}
          options[:src] = src if src.present?
          options
        end

        def scoped?
          scope.present?
        end

        def turbo_frame_id
          parts = if scoped?
            [
              scope[:model],
              scope[:id],
              scope[:field]
            ]
          else
            [repository.controller_name]
          end
          parts.compact.join("_")
        end
      end
    end
  end
end
