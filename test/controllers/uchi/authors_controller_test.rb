require "test_helper"

module Uchi
  class AuthorsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @author = Author.create!(name: "Test Author")
    end

    test "#repository_class returns the correct repository class" do
      controller = Uchi::AuthorsController.new
      assert_equal Uchi::Repositories::Author, controller.send(:repository_class)
    end

    test "GET edit renders successfully" do
      get edit_uchi_author_url(id: @author.id)
      assert_response :success
    end

    test "GET edit renders the edit view" do
      get edit_uchi_author_url(id: @author.id)
      assert_template :edit
    end

    test "GET index responds successfully" do
      get uchi_authors_url
      assert_response :success
    end

    test "GET index renders the index view" do
      get uchi_authors_url
      assert_template :index
    end

    test "GET new renders successfully" do
      get new_uchi_author_url
      assert_response :success
    end

    test "GET new renders the new view" do
      get new_uchi_author_url
      assert_template :new
    end

    test "GET show responds successfully" do
      get uchi_author_url(id: @author.id)
      assert_response :success
    end

    test "GET show renders the show view" do
      get uchi_author_url(id: @author.id)
      assert_template :show
    end

    test "PATCH update redirects to show after successful update" do
      srand(42)
      patch uchi_author_url(id: @author.id), params: {author: {name: "Updated Name"}}
      assert_redirected_to uchi_author_url(id: @author.id, uniq: 0.3745401188473625)
    end

    test "PATCH update responds with 303 after successful update" do
      patch uchi_author_url(id: @author.id), params: {author: {name: "Updated Name"}}
      assert_response :see_other
    end

    test "PATCH update changes the author's attributes" do
      patch uchi_author_url(id: @author.id), params: {author: {name: "Updated Name"}}
      @author.reload
      assert_equal "Updated Name", @author.name
    end

    test "PATCH update flashes a translated success message after successful update" do
      ::I18n.with_locale(:da) do
        patch uchi_author_url(id: @author.id), params: {author: {name: "Updated Name"}}
        assert_equal "Dine ændringer til forfatteren blev gemt", flash[:success]
      end
    end

    test "PATCH update falls back to default success message after successful update" do
      patch uchi_author_url(id: @author.id), params: {author: {name: "Updated Name"}}
      assert_equal "Your changes have been saved", flash[:success]
    end

    test "PATCH update rerenders the edit view after unsuccessful update" do
      patch uchi_author_url(id: @author.id), params: {author: {name: ""}}
      assert_template :edit
    end

    test "PATCH responds with 422 after unsuccessful update" do
      patch uchi_author_url(id: @author.id), params: {author: {name: ""}}
      assert_response :unprocessable_entity
    end

    test "POST create redirects to show after successful creation" do
      post uchi_authors_url, params: {author: {name: "New Author"}}
      assert_redirected_to uchi_author_url(id: Author.last.id)
    end

    test "POST create responds with 303 after successful creation" do
      post uchi_authors_url, params: {author: {name: "New Author"}}
      assert_response :see_other
    end

    test "POST create flashes a translated success message after successful creation" do
      ::I18n.with_locale(:da) do
        post uchi_authors_url, params: {author: {name: "New Author"}}
        assert_equal "Forfatteren er blevet tilføjet", flash[:success]
      end
    end

    test "POST create creates a new author" do
      post uchi_authors_url, params: {author: {name: "New Author"}}
      assert_equal "New Author", Author.last.name
    end

    test "POST create rerenders the new view after unsuccessful creation" do
      post uchi_authors_url, params: {author: {name: ""}}
      assert_template :new
    end

    test "POST create responds with 422 after unsuccessful creation" do
      post uchi_authors_url, params: {author: {name: ""}}
      assert_response :unprocessable_entity
    end
  end
end
