require "test_helper"

# Test repository capturing the context its searchable lambda is called with
class BookWithContextCapturingSearchRepository < Uchi::Repository
  class << self
    attr_accessor :captured_context
  end

  def self.model
    Book
  end

  def fields
    [
      Uchi::Field::String.new(:original_title).searchable(lambda { |context:, query:, term:|
        self.class.captured_context = context
        query.where(original_title: term)
      })
    ]
  end
end

module Uchi
  module Search
    class ResultsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @hobbit = Book.create!(original_title: "The Hobbit")
        @silmarillion = Book.create!(original_title: "The Silmarillion")
      end

      test "GET index responds successfully" do
        get uchi.search_results_path(repository: "books", query: "Hobbit")
        assert_response :success
      end

      test "GET index links to matching records" do
        get uchi.search_results_path(repository: "books", query: "Hobbit")

        assert_select "a[data-turbo-frame='_top'][href=?]", Rails.application.routes.url_helpers.uchi_book_path(@hobbit.id)
        assert_select "a[href=?]", Rails.application.routes.url_helpers.uchi_book_path(@silmarillion.id), count: 0
      end

      test "GET index shows a heading with the repository name when there are matches" do
        get uchi.search_results_path(repository: "books", query: "Hobbit")

        assert_select "h2", text: "Books"
      end

      test "GET index renders nothing when there are no matches" do
        get uchi.search_results_path(repository: "books", query: "nonexistent")

        assert_select "h2", count: 0
        assert_select "a", count: 0
      end

      test "GET index raises when the repository is unknown" do
        assert_raises(NameError) do
          get uchi.search_results_path(repository: "unknown", query: "Hobbit")
        end
      end

      test "GET index sets the context's view to :index before searching" do
        original_repository = Uchi::Repositories::Book
        Uchi::Repositories.send(:remove_const, :Book)
        Uchi::Repositories.const_set(:Book, BookWithContextCapturingSearchRepository)
        BookWithContextCapturingSearchRepository.captured_context = nil

        begin
          get uchi.search_results_path(repository: "books", query: "Hobbit")
        ensure
          Uchi::Repositories.send(:remove_const, :Book)
          Uchi::Repositories.const_set(:Book, original_repository)
        end

        assert_equal :index, BookWithContextCapturingSearchRepository.captured_context&.view&.to_sym
      end
    end
  end
end
