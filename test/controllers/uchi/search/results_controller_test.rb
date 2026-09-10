require "test_helper"

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
        # Because Uchi::Engine is mounted with isolate_namespace, processing a
        # request routed into the engine sets `@request.script_name` to "/uchi"
        # for the rest of the test session. Any subsequent call to a main-app
        # route helper (like edit_uchi_book_path) then picks up that leftover
        # script_name and prepends it again, producing /uchi/uchi/books/1/edit
        # instead of /uchi/books/1/edit.
        path_to_hobbit = uchi_book_path(@hobbit.id)
        path_to_silmarillion = uchi_book_path(@silmarillion.id)

        get uchi.search_results_path(repository: "books", query: "Hobbit")

        assert_select "a[data-turbo-frame='_top'][href=?]", path_to_hobbit
        assert_select "a[href=?]", path_to_silmarillion, count: 0
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
    end
  end
end
