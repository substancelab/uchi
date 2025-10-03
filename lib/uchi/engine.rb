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

    initializer "uchi.autoload" do |app|
      # Preserve Uchi as a namespace for autoloading from app/uchi
      # See https://github.com/fxn/zeitwerk/issues/250 for details
      ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/uchi")

      uchi_directory = Rails.root.join("app/uchi")
      if uchi_directory.exist?
        Rails.autoloaders.main.push_dir(uchi_directory, namespace: Uchi)
      end
    end
  end
end
