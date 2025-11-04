# frozen_string_literal: true

module Uchi
  module I18n
    module_function

    def translate(key, **options)
      scope = options.delete(:scope)
      scope ||= "uchi" unless key.to_s.start_with?("uchi.")
      ::I18n.translate(key, **options, scope: scope)
    end
  end
end
