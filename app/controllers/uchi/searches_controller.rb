# frozen_string_literal: true

module Uchi
  class SearchesController < Uchi::ApplicationController
    def show
      @query = params[:query]
      @repositories = Uchi::Repository.all.map(&:new).select(&:searchable?)
    end
  end
end
