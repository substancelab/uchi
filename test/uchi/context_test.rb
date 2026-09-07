require "test_helper"

class UchiContextTest < ActiveSupport::TestCase
  def setup
    @context = Uchi::Context.new
  end

  test "#repository reads and writes" do
    repository = Object.new
    @context.repository = repository

    assert_equal repository, @context.repository
  end

  test "#user reads and writes" do
    user = Object.new
    @context.user = user

    assert_equal user, @context.user
  end

  test "#view reads and writes" do
    @context.view = :index

    assert_equal :index, @context.view
  end

  test "attributes default to nil" do
    assert_nil @context.repository
    assert_nil @context.user
    assert_nil @context.view
  end
end
