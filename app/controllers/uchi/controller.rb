# frozen_string_literal: true

require "uchi/context"

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

    before_action :set_uchi_context

    protected

    attr_reader :uchi_context
    helper_method :uchi_context

    def set_uchi_context
      @uchi_context = Uchi::Context.new
    end
  end
end
