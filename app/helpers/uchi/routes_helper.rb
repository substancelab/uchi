module Uchi
  module RoutesHelper
    # Generates a path to a named route inside the Uchi engine, e.g. `:search`
    # for `search_path`.
    #
    # This is a thin wrapper around `Uchi::Routes#path_to` that supplies the
    # current request's script name, so links and forms keep pointing at the
    # right place when the host application itself is served from a sub-URI
    # (e.g. Rack `SCRIPT_NAME`). See `Uchi::Routes#path_to` for why this can't
    # just go through the `uchi` routes proxy Rails generates for the mount.
    def uchi_path_to(name, **options)
      Uchi.routes.path_to(name, script_name: request.script_name, **options)
    end
  end
end
