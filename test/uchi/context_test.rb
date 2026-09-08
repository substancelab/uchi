require "test_helper"

class UchiContextTest < ActiveSupport::TestCase
  def setup
    @context = Uchi::Context.new
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

  test "#view= accepts nil" do
    @context.view = nil

    assert_nil @context.view
  end

  test "#view= accepts String" do
    @context.view = "new"

    assert_equal Uchi::View.new(:new), @context.view
  end

  test "#view= raises ArgumentError for false" do
    assert_raises(ArgumentError) do
      @context.view = false
    end
  end

  test "#view= raises ArgumentError for an unknown view name" do
    assert_raises(ArgumentError) do
      @context.view = :bogus
    end
  end

  test "#view= raises ArgumentError for a value that can't resolve to a view" do
    assert_raises(ArgumentError) do
      @context.view = Object.new
    end
  end

  test "attributes default to nil" do
    assert_nil @context.repository
    assert_nil @context.user
    assert_nil @context.view
  end
end
