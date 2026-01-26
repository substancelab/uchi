module Uchi
  class Routes
    # Mounts the Uchi engine routes onto the host application's routes.
    #
    # Example usage in host application's routes.rb that install Uchi at /uchi:
    #
    #  Rails.application.routes.draw do
    #    Uchi.routes.mount(self)
    #  end
    #
    # @param host_routes [ActionDispatch::Routing::Mapper] The host
    # application's routes mapper.
    #
    # @param at [Symbol] The path segment where Uchi should be mounted.
    def mount(host_routes, at: default_at)
      @mount_at = at.to_sym
      host_routes.mount(
        Uchi::Engine,
        as: mount_as,
        at: mount_at
      )

      draw_repository_routes(host_routes, at: mount_at)
    end

    def draw_root_route(routes, repository:, at: default_at)
      return unless repository

      routes.namespace(at, as: mount_as) do
        routes.root to: "#{repository.controller_name}#index"
      end
    end

    def draw_repository_routes(routes, at: default_at)
      repositories = Uchi::Repository.all
      repositories.each do |repository_class|
        resources_name = repository_class.controller_name
        routes.namespace(at, as: mount_as) do
          routes.resources(resources_name)
        end
      end

      draw_root_route(routes, at: at, repository: repositories.first)
    end

    # Returns the name to use when generating routing helper method names
    def mount_as
      :uchi
    end

    # Returns the path prefix for the routes, i.e. the first URL segment where
    # Uchi can be requested.
    def mount_at
      @mount_at ||= default_at
    end

    private

    def default_at
      :uchi
    end

    def mount_path
      mount_at
    end
  end
end
