# frozen_string_literal: true

module Uchi
  # Context class for Uchi framework, used to encapsulate request-specific data
  # and state.
  class Context
    # @return [User, nil] the user associated with the context
    attr_accessor :user

    # @return [Uchi::View, nil] the view associated with the context
    attr_reader :view

    # Set the view for the context. Accepts a Uchi::View instance or a value
    # that can be converted to one.
    #
    # @param value [Uchi::View, Symbol, String, nil] the view to set
    # @raise [ArgumentError] if the value cannot be converted to a Uchi::View
    def view=(value)
      value = Uchi::View.new(value) unless value.nil? || value.is_a?(Uchi::View)
      @view = value
    end
  end
end
