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

  test "views wrapping the same name have the same hash" do
    assert_equal Uchi::View.new(:show).hash, Uchi::View.new(:show).hash
  end

  test "can be used as a Hash key interchangeably with another instance wrapping the same name" do
    hash = {Uchi::View.new(:show) => "value"}

    assert_equal "value", hash[Uchi::View.new(:show)]
  end

  test "de-duplicates in a Set with another instance wrapping the same name" do
    assert_equal 1, Set[Uchi::View.new(:show), Uchi::View.new(:show)].size
  end

  test "#to_s returns the name as a string" do
    assert_equal "show", Uchi::View.new(:show).to_s
  end

  test "raises when given an unknown view name" do
    assert_raises(ArgumentError) { Uchi::View.new(:preview) }
  end

  test "#index? returns true only for the index view" do
    assert Uchi::View.new(:index).index?
    assert_not Uchi::View.new(:show).index?
  end

  test "#show? returns true only for the show view" do
    assert Uchi::View.new(:show).show?
    assert_not Uchi::View.new(:index).show?
  end

  test "#new? returns true only for the new view" do
    assert Uchi::View.new(:new).new?
    assert_not Uchi::View.new(:index).new?
  end

  test "#edit? returns true only for the edit view" do
    assert Uchi::View.new(:edit).edit?
    assert_not Uchi::View.new(:index).edit?
  end
end
