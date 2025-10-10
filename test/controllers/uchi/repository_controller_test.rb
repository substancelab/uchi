require "test_helper"

module Uchi
  class RepositoryControllerTest < ActionDispatch::IntegrationTest
    setup do
      @book = Book.create!(original_title: "The Hobbit")
    end

    test "GET index links to show for each record" do
      get uchi_books_url

      assert_select "tr td a[data-turbo-frame='_top'][href=?]", uchi_book_path(id: @book.id)
    end

    test "GET index links to edit for each record" do
      get uchi_books_url
      assert_select "tr td a[data-turbo-frame='_top'][href=?]", edit_uchi_book_path(id: @book.id)
    end

    test "GET show responds successfully" do
      get uchi_book_url(id: @book.id)
      assert_response :success
    end

    test "GET show renders the show view" do
      get uchi_book_url(id: @book.id)
      assert_template :show
    end

    test "GET show includes a turbo-frame that loads the titles in a scoped index view" do
      get uchi_book_url(id: @book.id)

      assert_select "turbo-frame[src]" do |node_set|
        tag = node_set.first
        src = tag.attributes["src"].value
        expected_src = uchi_titles_path(scope: {
          model: "Book",
          id: @book.id,
          field: "titles",
          inverse_of: "book"
        })
        assert_equal expected_src, src
      end
    end
  end
end
