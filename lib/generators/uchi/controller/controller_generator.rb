# frozen_string_literal: true

module Uchi
  class ControllerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def create_controller_file
      destination = File.join("app/controllers/uchi")
      template "controller.rb", File.join(destination, "#{file_name}_controller.rb")
    end

    def add_route
      route "resources :#{plural_file_name}", namespace: :uchi
    end
  end
end
