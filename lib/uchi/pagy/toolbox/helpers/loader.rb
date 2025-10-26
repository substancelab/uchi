# frozen_string_literal: true

module Uchi
  class Pagy
    module Loader
      paths = { public:    { page_url:                'page_url' } }.freeze

      paths.each do |visibility, methods|
        send(visibility)
        # Load the method, overriding its own alias. Next requests will call the method directly.
        define_method(:"load_#{visibility}") do |*args, **kwargs|
          require_relative methods[__callee__]
          send(__callee__, *args, **kwargs)
        end
        methods.each_key { |method| alias_method method, :"load_#{visibility}" }
      end
    end
  end
end
