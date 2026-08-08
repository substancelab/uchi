# frozen_string_literal: true

module Uchi
  module Search
    # Companion controller for the global search page. Each searchable
    # repository's results are loaded into their own Turbo Frame, backed by
    # this controller, so a slow search on one repository doesn't hold up the
    # others.
    class ResultsController < Uchi::ApplicationController
      layout false

      RESULTS_LIMIT = 5

      def index
        @repository = repository
        @query = params[:query]
        @records = @query.present? ? @repository.find_all(search: @query).limit(RESULTS_LIMIT) : @repository.model.none
      end

      private

      def repository
        repository_class = Uchi::Repository.all.find { |candidate| candidate.controller_name == params[:repository] }
        raise NameError, "No repository found for #{params[:repository]}" unless repository_class

        repository_class.new
      end
    end
  end
end
