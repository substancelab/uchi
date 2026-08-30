# frozen_string_literal: true

module Uchi
  class Action
    module Configuration
      def initialize(*args)
        super
        @on = default_on
      end

      # Sets or gets which contexts this action should appear in.
      #
      # When called with arguments, sets the contexts and returns self for
      # chaining. When called without arguments, returns the current contexts.
      #
      # @param views [Array<Symbol>] The views where this action should appear
      #   (e.g., :index, :show)
      # @return [self, Array<Symbol>] Returns self for method chaining when
      #   setting, or the views array when getting
      #
      # @example Setting
      #   Uchi::Action::Edit.new.on(:index, :show)
      #
      # @example Getting
      #   action.on # => [Uchi::View::INDEX, Uchi::View::SHOW]
      def on(*views)
        return @on if views.empty?

        @on = views.flatten.map { |view| Uchi::View.new(view) }

        self
      end

      protected

      def default_on
        [Uchi::View::SHOW]
      end
    end
  end
end
