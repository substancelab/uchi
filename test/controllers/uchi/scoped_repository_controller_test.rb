require "test_helper"

module Uchi
  class ScopedRepositoryControllerTest < ActionDispatch::IntegrationTest
    setup do
      @book = Book.create!(original_title: "The Hobbit")
    end

    test "GET index responds successfully" do
      get uchi_titles_url(scope: {model: "Book", id: @book.id, field: "titles"})
      assert_response :success
    end

    test "GET index renders the index view" do
      get uchi_titles_url(scope: {model: "Book", id: @book.id, field: "titles"})
      assert_template :index
    end

    test "GET index includes a turbo-frame" do
      get uchi_titles_url(scope: {model: "Book", id: @book.id, field: "titles"})
      assert_select "turbo-frame"
    end
  end
end
