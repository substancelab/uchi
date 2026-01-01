# frozen_string_literal: true

module Uchi
  class InstallGenerator < Rails::Generators::Base
    def create_namespace_in_routes
      route "namespace :uchi do\nend"
    end

    def mount_engine
      route "Uchi.routes.mount(self)"
    end
  end
end
