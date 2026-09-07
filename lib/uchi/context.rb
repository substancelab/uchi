# frozen_string_literal: true

module Uchi
  # Context class for Uchi framework, used to encapsulate request-specific data
  # and state.
  class Context
    attr_accessor \
      :repository,
      :user,
      :view
  end
end
