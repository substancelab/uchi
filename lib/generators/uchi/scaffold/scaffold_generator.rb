# frozen_string_literal: true

require "rails/generators/rails/resource/resource_generator"

module Uchi
  class ScaffoldGenerator < Rails::Generators::ResourceGenerator # :nodoc:
    remove_hook_for :resource_controller
    remove_hook_for :resource_route
    remove_class_option :actions

    def generate_repository
      generate("uchi:repository", name)
    end
  end
end
