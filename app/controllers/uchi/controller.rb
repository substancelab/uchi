# frozen_string_literal: true

module Uchi
  class Controller < ActionController::Base
    layout "uchi/application"

    protected

    helper_method def uchi_user
      current_user
    end
  end
end
