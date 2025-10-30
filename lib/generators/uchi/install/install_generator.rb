# frozen_string_literal: true

module Uchi
  class InstallGenerator < Rails::Generators::Base
    def create_namespace_in_routes
      route "namespace :uchi do\nend"
    end

    def mount_engine
      route "mount Uchi::Engine, at: \"/uchi\""
    end
  end
end
