module Uchi
  class AuthorsController < Uchi::RepositoryController
    def repository_class
      Uchi::Repositories::Author
    end
  end
end
