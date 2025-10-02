require "test_helper"

class UchiSortOrderTest < ActiveSupport::TestCase
  test ".from_params returns nil when no params are given" do
    assert_nil Uchi::SortOrder.from_params({})
  end

  test ".from_params defaults to ascending when direction isn't given" do
    sort_order = Uchi::SortOrder.from_params(sort: {by: :name})
    assert_instance_of Uchi::SortOrder, sort_order
    assert_equal :name, sort_order.name
    assert_equal :asc, sort_order.direction
  end

  test ".from_params returns a new SortOrder when both 'by' and 'direction' are given" do
    sort_order = Uchi::SortOrder.from_params(sort: {by: :born_on, direction: :desc})
    assert_instance_of Uchi::SortOrder, sort_order
    assert_equal :born_on, sort_order.name
    assert_equal :desc, sort_order.direction
  end

  test "#ascending? returns true when direction is :asc" do
    assert Uchi::SortOrder.new(:id, :asc).ascending?
  end

  test "#ascending? returns false when direction is :desc" do
    assert_not Uchi::SortOrder.new(:id, :desc).ascending?
  end

  test "#apply applies the sort order to the given query" do
    sort_order = Uchi::SortOrder.new(:name, :desc)
    query = Author.all

    sorted_query = sort_order.apply(query)

    assert_includes sorted_query.to_sql, "ORDER BY \"authors\".\"name\" DESC"
    assert_equal sorted_query, query.order(name: :desc)
  end

  test "#descending? returns false when direction is :asc" do
    assert_not Uchi::SortOrder.new(:id, :asc).descending?
  end

  test "#descending? returns true when direction is :desc" do
    assert Uchi::SortOrder.new(:id, :desc).descending?
  end
end
