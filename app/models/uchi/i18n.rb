# frozen_string_literal: true

module Uchi
  module I18n
    module_function

    def translate(key, **options)
      scope = options.delete(:scope) || "uchi"
      ::I18n.translate(key, **options, scope: scope)
    end
  end
end
