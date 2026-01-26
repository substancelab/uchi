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

  test "#root_path returns the root path with default mount" do
    assert_equal "/uchi/", @routes.root_path
  end

  test "#root_path respects custom mount path" do
    # Simulate mounting at a custom path
    original_mount_at = Uchi.routes.instance_variable_get(:@mount_at)
    begin
      Uchi.routes.instance_variable_set(:@mount_at, :admin)
      repository = Uchi::Repositories::Author.new
      routes = repository.routes

      assert_equal "/admin/", routes.root_path
    ensure
      # Restore original mount path
      if original_mount_at
        Uchi.routes.instance_variable_set(:@mount_at, original_mount_at)
      else
        Uchi.routes.instance_variable_set(:@mount_at, nil)
      end
    end
  end

  test "uchi_path uses mount_at when set" do
    original_mount_path = Uchi.routes.instance_variable_get(:@mount_at)
    begin
      Uchi.routes.instance_variable_set(:@mount_at, :admin)

      repository = Uchi::Repositories::Author.new
      routes = repository.routes

      assert_equal :admin, routes.send(:uchi_path)
    ensure
      # Restore original mount path
      if original_mount_path
        Uchi.routes.instance_variable_set(:@mount_at, original_mount_path)
      else
        Uchi.routes.instance_variable_set(:@mount_at, nil)
      end
    end
  end

  test "uchi_path defaults to :uchi when mount_at is not set" do
    # Ensure mount_path is not set
    original_mount_at = Uchi.routes.instance_variable_get(:@mount_at)
    begin
      Uchi.routes.instance_variable_set(:@mount_at, nil)

      repository = Uchi::Repositories::Author.new
      routes = repository.routes

      assert_equal :uchi, routes.send(:uchi_path)
    ensure
      # Restore original mount path
      if original_mount_at
        Uchi.routes.instance_variable_set(:@mount_at, original_mount_at)
      else
        Uchi.routes.instance_variable_set(:@mount_at, nil)
      end
    end
  end
end
