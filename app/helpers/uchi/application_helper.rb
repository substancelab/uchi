module Uchi
  module ApplicationHelper
    # Maps Rails flash types to Flowbite Toast styles
    def flash_style(flash_type)
      case flash_type.to_sym
      when :success
        :success
      when :alert, :error
        :danger
      when :warning
        :warning
      else
        :default
      end
    end
  end
end
