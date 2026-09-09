require "test_helper"

class UchiViewTest < ActiveSupport::TestCase
  test "wraps a symbol" do
    assert_equal :show, Uchi::View.new(:show).to_sym
  end

  test "converts a string name to a symbol" do
    assert_equal :show, Uchi::View.new("show").to_sym
  end

  test "is equal to the symbol it wraps" do
    assert Uchi::View.new(:show) == :show
  end

  test "is equal to another view wrapping the same name" do
    assert_equal Uchi::View.new(:show), Uchi::View.new(:show)
  end

  test "is not equal to a different symbol" do
    assert_not Uchi::View.new(:show) == :edit
  end

  test "is included in an Array of symbols it matches" do
    assert [Uchi::View.new(:edit), Uchi::View.new(:show)].include?(:show)
  end

  test "#to_s returns the name as a string" do
    assert_equal "show", Uchi::View.new(:show).to_s
  end

  test "raises when given an unknown view name" do
    assert_raises(ArgumentError) { Uchi::View.new(:preview) }
  end
end
