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
    #
    # @yield Extra routes to draw inside the Uchi namespace, e.g. to show a
    # specific repository at the root URL:
    #
    #  Uchi.routes.mount(self) do
    #    root to: "projects#index"
    #  end
    def mount(host_routes, at: default_at, &block)
      @mount_at = (at || default_at).to_sym
      host_routes.mount(
        Uchi::Engine,
        as: mount_as,
        at: mount_at
      )

      draw_repository_routes(host_routes, at: mount_at, &block)
    end

    def draw_root_route(routes, repository:, at: default_at)
      return unless repository

      routes.namespace(at, as: mount_as) do
        routes.root to: "#{repository.controller_name}#index"
      end
    end

    def draw_repository_routes(routes, at: default_at, &block)
      repositories = Uchi::Repository.all

      repositories.each do |repository_class|
        resources_name = repository_class.controller_name
        routes.namespace(at, as: mount_as) do
          routes.resources(resources_name)
        end
      end

      routes.namespace(at, as: mount_as, &block) if block

      draw_root_route(routes, at: at, repository: repositories.first) unless routes.has_named_route?(root_route_name)
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

    # Generates a path to a named route inside the Uchi engine, e.g. `:search`
    # for `search_path`.
    #
    # This calls the engine's own url helpers directly, with an explicit
    # `script_name`, instead of going through the `uchi` routes proxy that Rails
    # generates for the mount (e.g. `helpers.uchi.search_path`).
    #
    # That proxy derives the script name by combining the current request's
    # script name with the mount's, a calculation that breaks down when Uchi is
    # mounted at a path with more than one segment (e.g. `at: "admin/uchi"`) and
    # the current request isn't itself routed through the engine (which is the
    # common case since repository controllers are drawn directly into the host
    # application's routes).
    def path_to(name, **options)
      Uchi::Engine.routes.url_helpers.public_send(
        "#{name}_path",
        **options,
        script_name: script_name
      )
    end

    # Returns the script name Uchi's engine routes are mounted at, e.g.
    # "/admin/uchi".
    def script_name
      "/#{mount_at}"
    end

    private

    def default_at
      :uchi
    end

    def mount_path
      mount_at
    end

    def root_route_name
      :"#{mount_as}_root"
    end
  end
end
