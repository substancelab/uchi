module Uchi
  class Routes
    # Mounts the Uchi engine routes onto the host application's routes.
    #
    # Example usage in host application's routes.rb that install Uchi at /uchi:
    #
    #  Rails.application.routes.draw do
    #    Uchi.routes.mount(self)
    #  end
    def mount(host_routes, at: default_at)
      host_routes.mount(
        Uchi::Engine,
        at: at
      )

      draw_repository_routes(host_routes, at: at)
    end

    def draw_repository_routes(routes, at: default_at)
      repositories = Uchi::Repository.all
      repositories.each do |repository_class|
        resources_name = repository_class.controller_name
        routes.namespace(at) do
          routes.resources(resources_name)
        end
      end
    end

    private

    def default_at
      "uchi"
    end
  end
end
