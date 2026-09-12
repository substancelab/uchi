require "test_helper"

class UchiRoutesTest < ActiveSupport::TestCase
  def setup
    @route_set = ActionDispatch::Routing::RouteSet.new
  end

  test "root defaults to the first repository, sorted alphabetically" do
    draw { Uchi.routes.mount(self) }

    assert_equal "uchi/authors", root_route.requirements[:controller]
  end

  test "a block passed to mount can override the root route" do
    draw {
      Uchi.routes.mount(self) do
        root to: "books#index"
      end
    }

    assert_equal "uchi/books", root_route.requirements[:controller]
  end

  test "a block passed to mount can override the root route at a custom mount path" do
    draw {
      Uchi.routes.mount(self, at: "admin") do
        root to: "books#index"
      end
    }

    assert_equal 1, root_routes.size, "expected the default root route to be suppressed, not just shadowed"
    assert_equal "admin/books", root_route.requirements[:controller]
    assert_equal "index", root_route.requirements[:action]
    assert_equal "/admin", @route_set.url_helpers.uchi_root_path
  end

  private

  def draw(&block)
    original_mount_at = Uchi.routes.instance_variable_get(:@mount_at)
    @route_set.draw(&block)
  ensure
    Uchi.routes.instance_variable_set(:@mount_at, original_mount_at)
  end

  def root_routes
    @route_set.routes.select { |route| route.name.to_s.end_with?("root") }
  end

  def root_route
    root_routes.first
  end
end
