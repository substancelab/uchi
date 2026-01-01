gem "turbo-rails"
require "turbo-rails"

gem "view_component"
require "view_component"

require "uchi/version"
require "uchi/engine"

require "uchi/action"
require "uchi/action_response"
require "uchi/field"
require "uchi/i18n"
require "uchi/repository"
require "uchi/routes"
require "uchi/sort_order"
require "uchi/repository/translate"

module Uchi
  def self.routes
    @routes ||= Routes.new
  end
end
