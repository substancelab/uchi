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

    test "GET new renders a form to create a new model, preserving the scope" do
      get new_uchi_title_url(scope: @scope)
      assert_select "form[action=?][method='post']", uchi_titles_path(scope: @scope)
    end

    test "GET new links back to the scoped model" do
      get new_uchi_title_url(scope: @scope)
      assert_select "a[href=?]", uchi_book_path(id: @book.id), text: "Cancel"
    end

    test "submitting the rendered new form associates the new record with the scoped parent record" do
      get new_uchi_title_url(scope: @scope)
      form_action = Nokogiri::HTML5(response.body).at_css("form[method='post']")["action"]

      post form_action, params: {title: {locale: "en-US", title: "The Hobbit"}}

      assert_equal @book, Title.last.book
    end

    test "POST create associates the new record with the scoped parent record" do
      post uchi_titles_url(scope: @scope), params: {
        title: {locale: "en-US", title: "The Hobbit"}
      }

      assert_equal @book, Title.last.book
    end

    test "POST create redirects back to the scoped parent record on success" do
      post uchi_titles_url(scope: @scope), params: {
        title: {locale: "en-US", title: "The Hobbit"}
      }

      assert_redirected_to uchi_book_path(id: @book.id)
    end

    test "GET new prefills the scoped parent record for a has_and_belongs_to_many association" do
      get new_uchi_author_url(scope: {model: "Book", id: @book.id, field: "authors"})

      assert_response :success
      assert_equal [@book], assigns(:record).books
    end

    test "POST create associates the new record with the scoped parent record for a has_and_belongs_to_many association" do
      post uchi_authors_url(scope: {model: "Book", id: @book.id, field: "authors"}), params: {
        author: {name: "J.R.R. Tolkien"}
      }

      assert_equal [@book], Author.last.books
    end

    test "POST create does not associate the new record when the scoped field targets a different model" do
      # Book has_many :titles targets Title, not Author, but Author does
      # happen to have a has_and_belongs_to_many :books association -- a
      # crafted scope like this shouldn't be able to piggyback on that.
      post uchi_authors_url(scope: {model: "Book", id: @book.id, field: "titles"}), params: {
        author: {name: "Suspicious Author"}
      }

      assert_empty Author.last.books
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
