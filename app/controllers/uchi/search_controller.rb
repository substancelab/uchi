# frozen_string_literal: true

module Uchi
  class SearchController < Uchi::ApplicationController
    def index
      @query = params[:query]
      @repositories = Uchi::Repository.all.map(&:new).select(&:searchable?)
    end
  end
end
