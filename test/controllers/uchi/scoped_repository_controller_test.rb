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

    test "GET index lists only the records associated with the parent record" do
      title1 = Title.create!(locale: "da-DK", title: "Hobbitten", book: @book)
      title2 = Title.create!(locale: "de-DE", title: "Der Hobbit", book: @book)

      other_book = Book.create!(original_title: "1984")
      Title.create!(locale: "de-DE", title: "1984", book: other_book)

      get uchi_titles_url(scope: {model: "Book", id: @book.id, field: "titles", inverse_of: "book"})

      assert_equal assigns(:records), [title1, title2]
    end

    test "GET index does not include the field for the parent record" do
      get uchi_titles_url(scope: {model: "Book", id: @book.id, field: "titles", inverse_of: "book"})

      assert_not assigns(:columns).find { |column| column.name == :book }
    end
  end
end
