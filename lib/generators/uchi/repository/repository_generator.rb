# frozen_string_literal: true

module Uchi
  class RepositoryGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def create_repository_file
      destination = File.join("app/uchi/repositories")
      template "repository.rb", File.join(destination, "#{file_name}.rb")
    end

    def generate_controller
      generate("uchi:controller", name)
    end
  end
end
