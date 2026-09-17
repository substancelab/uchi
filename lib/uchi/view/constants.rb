# frozen_string_literal: true

require "uchi/view"

module Uchi
  class View
    # Define some commonly used views as constants for convenience.
    EDIT = new(:edit)
    INDEX = new(:index)
    NEW = new(:new)
    SHOW = new(:show)

    # Shorthand for all views.
    ALL = [EDIT, INDEX, NEW, SHOW]
  end
end
