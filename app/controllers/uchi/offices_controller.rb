# frozen_string_literal: true

module Uchi
  class OfficesController < Uchi::RepositoryController
    private

    def repository_class
      Uchi::Repositories::Office
    end
  end
end
