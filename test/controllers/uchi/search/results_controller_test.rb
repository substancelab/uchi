require "test_helper"

module Uchi
  module Search
    class ResultsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @hobbit = Book.create!(original_title: "The Hobbit")
        @silmarillion = Book.create!(original_title: "The Silmarillion")
      end

      test "GET index responds successfully" do
        get uchi_search_results_url(repository: "books", query: "Hobbit")
        assert_response :success
      end

      test "GET index links to matching records" do
        get uchi_search_results_url(repository: "books", query: "Hobbit")

        assert_select "a[data-turbo-frame='_top'][href=?]", uchi_book_path(id: @hobbit.id)
        assert_select "a[href=?]", uchi_book_path(id: @silmarillion.id), count: 0
      end

      test "GET index shows a heading with the repository name when there are matches" do
        get uchi_search_results_url(repository: "books", query: "Hobbit")

        assert_select "h2", text: "Books"
      end

      test "GET index renders nothing when there are no matches" do
        get uchi_search_results_url(repository: "books", query: "nonexistent")

        assert_select "h2", count: 0
        assert_select "a", count: 0
      end

      test "GET index raises when the repository is unknown" do
        assert_raises(NameError) do
          get uchi_search_results_url(repository: "unknown", query: "Hobbit")
        end
      end
    end
  end
end
