module Uchi
  class Plugins
    attr_reader :registered

    def hook(hook_name, **kwargs)
      registered.each do |plugin_class|
        next unless plugin_class.hooks_into?(hook_name)

        plugin_class.hook(hook_name, **kwargs)
      end
    end

    def initialize
      @registered = []
    end

    def register(plugin_class)
      @registered << plugin_class
    end
  end
end
