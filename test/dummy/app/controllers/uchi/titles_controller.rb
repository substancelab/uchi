module Uchi
  class TitlesController < Uchi::RepositoryController
    def repository_class
      Uchi::Repositories::Title
    end
  end
end
