# frozen_string_literal: true

module Uchi
  class MeetingRoomsController < Uchi::RepositoryController
    private

    def repository_class
      Uchi::Repositories::MeetingRoom
    end
  end
end
