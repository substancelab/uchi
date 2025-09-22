module Uchi
  class Engine < ::Rails::Engine
    isolate_namespace Uchi

    initializer "uchi.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/assets/javascripts")
        app.config.assets.precompile += %w[uchi_manifest]
      end
    end
  end
end
