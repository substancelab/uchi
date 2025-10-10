require "test_helper"

module Uchi
  class ScopedRepositoryControllerTest < ActionDispatch::IntegrationTest
    setup do
      @book = Book.create!(original_title: "The Hobbit")
      @dk_title = Title.create!(book: @book, locale: "da-DK", title: "Hobbitten")
      @de_title = Title.create!(locale: "de-DE", title: "Der Hobbit", book: @book)

      @scope = {model: "Book", id: @book.id, field: "titles"}
    end

    test "GET edit responds successfully" do
      get edit_uchi_title_url(id: @dk_title.id, scope: @scope)
      assert_response :success
    end

    test "GET edit renders a form for updating the model" do
      get edit_uchi_title_url(id: @dk_title.id, scope: @scope)
      assert_select "form[action=?][method='post']", uchi_title_path(id: @dk_title.id)
    end

    test "GET edit links back to the scoped model" do
      get edit_uchi_title_url(id: @dk_title.id, scope: @scope)
      assert_select "a[href=?]", uchi_book_path(id: @book.id), text: "Cancel"
    end

    test "GET new responds successfully" do
      get new_uchi_title_url(scope: @scope)
      assert_response :success
    end

    test "GET new renders a form to create a new model" do
      get new_uchi_title_url(scope: @scope)
      assert_select "form[action=?][method='post']", uchi_titles_path
    end

    test "GET new links back to the scoped model" do
      get new_uchi_title_url(scope: @scope)
      assert_select "a[href=?]", uchi_book_path(id: @book.id), text: "Cancel"
    end

    test "GET index responds successfully" do
      get uchi_titles_url(scope: @scope)
      assert_response :success
    end

    test "GET index renders the index view" do
      get uchi_titles_url(scope: @scope)
      assert_template :index
    end

    test "GET index includes a turbo-frame" do
      get uchi_titles_url(scope: @scope)
      assert_select "turbo-frame"
    end

    test "GET index lists only the records associated with the parent record" do
      other_book = Book.create!(original_title: "1984")
      Title.create!(locale: "de-DE", title: "1984", book: other_book)

      get uchi_titles_url(scope: @scope.merge(inverse_of: "book"))

      assert_equal assigns(:records), [@dk_title, @de_title]
    end

    test "GET index does not include the field for the parent record" do
      get uchi_titles_url(scope: @scope.merge(inverse_of: "book"))

      assert_not assigns(:columns).find { |column| column.name == :book }
    end
  end
end
