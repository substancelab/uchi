# frozen_string_literal: true

# Base controller for Uchi namespace.
#
# All Uchi controllers should inherit from Uchi::ApplicationController. This
# controller is here to provide us a set of defaults that can be overridden in
# consumer code.
module Uchi
  class Controller < ActionController::Base
    layout "uchi/application"

    protected

    helper_method def uchi_user
      current_user
    end
  end
end
