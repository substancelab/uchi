# frozen_string_literal: true

module Uchi
  class ReservationsController < Uchi::RepositoryController
    private

    def repository_class
      Uchi::Repositories::Reservation
    end
  end
end
