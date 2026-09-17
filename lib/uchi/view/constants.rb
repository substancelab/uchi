# frozen_string_literal: true

require "uchi/view" unless defined?(Uchi::View)

module Uchi
  class View
    # Define some commonly used views as constants for convenience.
    EDIT = new(:edit).freeze
    INDEX = new(:index).freeze
    NEW = new(:new).freeze
    SHOW = new(:show).freeze

    # Shorthand for all views.
    ALL = [EDIT, INDEX, NEW, SHOW].freeze

    # Shorthand for views with a form
    FORM = [EDIT, NEW].freeze
  end
end
