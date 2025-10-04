require "test_helper"
require "ostruct"

class UchiFieldTest < ActiveSupport::TestCase
  def setup
    @field = Uchi::Field.new(:name)
  end

  test "initializes with name" do
    field = Uchi::Field.new(:title)
    assert_equal :title, field.name
  end

  test "converts string name to symbol" do
    field = Uchi::Field.new("title")
    assert_equal :title, field.name
  end

  test "has default options" do
    assert_equal [:edit, :index, :show], @field.on
    assert_equal true, @field.sortable
  end

  test "#column_name returns humanized name" do
    field = Uchi::Field.new(:first_name)
    assert_equal "First name", field.column_name
  end

  test "#param_key returns name as symbol" do
    assert_equal :name, @field.param_key
  end

  test "#searchable? returns false by default" do
    assert_not @field.searchable?
  end

  test "#searchable? returns true when explicitly set" do
    field = Uchi::Field.new(:name, searchable: true)
    assert field.searchable?
  end

  test "#sortable? returns true by default" do
    assert @field.sortable?
  end

  test "#sortable? returns false when explicitly set" do
    field = Uchi::Field.new(:name, sortable: false)
    assert_not field.sortable?
  end

  test "#value uses reader to get value from record" do
    record = OpenStruct.new(name: "Test Name")
    assert_equal "Test Name", @field.value(record)
  end

  test "#value uses custom reader when provided" do
    custom_reader = ->(record, field_name) { "Custom: #{record.public_send(field_name)}" }
    field = Uchi::Field.new(:name, reader: custom_reader)
    record = OpenStruct.new(name: "Test")

    assert_equal "Custom: Test", field.value(record)
  end
end
