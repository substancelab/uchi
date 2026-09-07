require "test_helper"

module Uchi
  class ContextTest < ActionDispatch::IntegrationTest
    setup do
      @author = Author.create!(name: "Test Author")
    end

    test "GET index sets #repository on the context" do
      get uchi_authors_url
      assert_equal Uchi::Repositories::Author, @controller.send(:uchi_context).repository.class
    end

    test "GET index sets #view to :index" do
      get uchi_authors_url
      assert_equal Uchi::View.new(:index), @controller.send(:uchi_context).view
    end

    test "GET show sets #view to :show" do
      get uchi_author_url(id: @author.id)
      assert_equal Uchi::View.new(:show), @controller.send(:uchi_context).view
    end

    test "GET new sets #view to :new" do
      get new_uchi_author_url
      assert_equal Uchi::View.new(:new), @controller.send(:uchi_context).view
    end

    test "GET edit sets #view to :edit" do
      get edit_uchi_author_url(id: @author.id)
      assert_equal Uchi::View.new(:edit), @controller.send(:uchi_context).view
    end

    test "POST create sets #view to :new" do
      post uchi_authors_url, params: {author: {name: "New Author"}}
      assert_equal Uchi::View.new(:new), @controller.send(:uchi_context).view
    end

    test "PATCH update sets #view to :edit" do
      patch uchi_author_url(id: @author.id), params: {author: {name: "Updated Name"}}
      assert_equal Uchi::View.new(:edit), @controller.send(:uchi_context).view
    end

    test "DELETE destroy sets #view to :index" do
      delete uchi_author_url(id: @author.id)
      assert_equal Uchi::View.new(:index), @controller.send(:uchi_context).view
    end

    test "#user defaults to nil when no current_user is configured" do
      get uchi_authors_url
      assert_nil @controller.send(:uchi_context).user
    end
  end
end
