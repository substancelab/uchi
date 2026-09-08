# frozen_string_literal: true

module Uchi
  class InstallGenerator < Rails::Generators::Base
    def mount_engine
      route "Uchi.routes.mount(self)"
    end
  end
end
