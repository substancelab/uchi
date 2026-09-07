# frozen_string_literal: true

# Base controller for Uchi namespace.
#
# All Uchi controllers should inherit from Uchi::ApplicationController. This
# controller is here to provide us a set of defaults that can be overridden in
# consumer code.
#
# - `Uchi::Controller` is an internal base controller for the Uchi engine, which
#   shouldn't be seen or used directly by consumer applications.
# - `Uchi::ApplicationController` is intended to be the base controller for
#   consumer applications, allowing them to customize behavior without touching
#   the internal `Uchi::Controller`.

module Uchi
  class Controller < ActionController::Base
    layout "uchi/application"

    protected

    helper_method def uchi_user
      current_user
    end
  end
end
