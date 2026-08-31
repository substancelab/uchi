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
      # When called with arguments, sets the contexts and returns self for chaining.
      # When called without arguments, returns the current contexts.
      #
      # @param contexts [Array<Symbol>] The contexts where this action should appear
      #   (e.g., :row, :show)
      # @return [self, Array<Symbol>] Returns self for method chaining when setting,
      #   or the contexts array when getting
      #
      # @example Setting
      #   Uchi::Action::Edit.new.on(:row, :show)
      #
      # @example Getting
      #   action.on # => [:row, :show]
      def on(*contexts)
        return @on if contexts.empty?

        @on = contexts.flatten
        self
      end

      protected

      def default_on
        [:row, :show]
      end
    end
  end
end
