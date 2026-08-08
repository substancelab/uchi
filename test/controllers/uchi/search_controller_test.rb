require "test_helper"

module Uchi
  class SearchControllerTest < ActionDispatch::IntegrationTest
    setup do
      @book = Book.create!(original_title: "The Hobbit")
    end

    test "GET index responds successfully" do
      get uchi_search_url(query: "Hobbit")
      assert_response :success
    end

    test "GET index responds successfully without a query" do
      get uchi_search_url
      assert_response :success
    end

    test "GET index renders a turbo frame for each searchable repository" do
      get uchi_search_url(query: "Hobbit")

      assert_select "turbo-frame#search_results_authors[src=?]", uchi_search_results_path(repository: "authors", query: "Hobbit")
      assert_select "turbo-frame#search_results_books[src=?]", uchi_search_results_path(repository: "books", query: "Hobbit")
      assert_select "turbo-frame#search_results_titles[src=?]", uchi_search_results_path(repository: "titles", query: "Hobbit")
    end

    test "GET index does not render any turbo frames without a query" do
      get uchi_search_url

      assert_select "turbo-frame", count: 0
    end
  end
end
