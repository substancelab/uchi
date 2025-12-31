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
    end

    private

    def default_at
      "uchi"
    end
  end
end
