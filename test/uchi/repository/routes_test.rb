require "test_helper"
require_relative "../../dummy/app/uchi/repositories/author"

class UchiRepositoryRoutesTest < ActiveSupport::TestCase
  def setup
    @repository = Uchi::Repositories::Author.new
    @routes = @repository.routes
  end

  test "initializes with repository" do
    assert_equal @repository, @routes.repository
  end

  test "#singular returns the singular route name" do
    assert_equal "author", @routes.singular
  end

  test "#plural returns the plural route name" do
    assert_equal "authors", @routes.plural
  end

  test "#path_for returns path to create action" do
    assert_equal "/uchi/authors", @routes.path_for(:create)
  end

  test "#path_for returns path to destroy action" do
    assert_equal "/uchi/authors/1", @routes.path_for(:destroy, id: 1)
  end

  test "#path_for returns path to edit action" do
    assert_equal "/uchi/authors/1/edit", @routes.path_for(:edit, id: 1)
  end

  test "#path_for returns path to index action" do
    assert_equal "/uchi/authors", @routes.path_for(:index)
  end

  test "#path_for returns path to new action" do
    assert_equal "/uchi/authors/new", @routes.path_for(:new)
  end

  test "#path_for returns path to show action" do
    assert_equal "/uchi/authors/1", @routes.path_for(:show, id: 1)
  end

  test "#path_for returns path to update action" do
    assert_equal "/uchi/authors/1", @routes.path_for(:update, id: 1)
  end
end
