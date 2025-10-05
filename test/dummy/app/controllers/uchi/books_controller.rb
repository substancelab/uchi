module Uchi
  class BooksController < Uchi::RepositoryController
    def repository_class
      Uchi::Repositories::Book
    end
  end
end
