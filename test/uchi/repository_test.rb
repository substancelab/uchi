require "test_helper"

require_relative "../dummy/app/uchi/repositories/author"

class UchiRepositoryTest < ActiveSupport::TestCase
  test ".all returns all Uchi::Repository's" do
    repositories = Uchi::Repository.all

    assert_equal \
      repositories.sort_by(&:name),
      [Uchi::Repositories::Author, Uchi::Repositories::Book, Uchi::Repositories::Title]
  end

  test ".for_model returns the repository for the given model" do
    assert_equal Uchi::Repositories::Author, Uchi::Repository.for_model(Author)
    assert_equal Uchi::Repositories::Author, Uchi::Repository.for_model("Author")
    assert_equal Uchi::Repositories::Author, Uchi::Repository.for_model(:Author)
  end

  test ".model returns the model class the repository manages" do
    assert_equal Author, Uchi::Repositories::Author.model
  end

  test "#build returns a new, unsaved instance of the model the repository manages" do
    author = author_repository.build(name: "Alice")

    assert author.is_a?(Author)
    assert_equal "Alice", author.name
    assert author.new_record?
  end

  test "#controller_name returns a URL slug for the controller" do
    assert_equal "authors", author_repository.controller_name
  end

  test "#default_sort_order returns a sort by id ascending" do
    sort_order = author_repository.default_sort_order

    assert sort_order.is_a?(Uchi::SortOrder)
    assert_equal :id, sort_order.name
    assert_equal :asc, sort_order.direction
  end

  test "#fields_for_edit returns fields to include on the edit page" do
    fields = author_repository.fields_for_edit

    assert_equal [:name, :born_on, :biography], fields.map(&:name)
  end

  test "#fields_for_index returns fields to include on the index page" do
    fields = author_repository.fields_for_index

    assert_equal [:id, :name, :born_on], fields.map(&:name)
  end

  test "#fields_for_show returns fields to include on the show page" do
    fields = author_repository.fields_for_show

    assert_equal [:id, :name, :born_on, :biography], fields.map(&:name)
  end

  test "#find_all returns all records of the model the repository manages" do
    alice = Author.create!(name: "Alice")
    bob = Author.create!(name: "Bob")

    authors = author_repository.find_all

    assert_equal [alice, bob], authors
  end

  # TODO: How to test this?
  # test "#find_all applies includes if given"

  test "#find_all applies a search query if given" do
    alice = Author.create!(name: "Alice")
    _bob = Author.create!(name: "Bob")

    authors = author_repository.find_all(search: "IC")

    assert_equal [alice], authors
  end

  test "#find_all applies a sort order if given" do
    alice = Author.create!(name: "Alice")
    bob = Author.create!(name: "Bob")

    authors = author_repository.find_all(sort_order: Uchi::SortOrder.new(:name, :desc))

    assert_equal [bob, alice], authors
  end

  test "#find returns a single record by its ID" do
    alice = Author.create!(name: "Alice")

    result = author_repository.find(alice.id)

    assert_equal alice, result
  end

  test "#find raises ActiveRecord::RecordNotFound when the record is not found" do
    assert_raises(ActiveRecord::RecordNotFound) do
      author_repository.find(42)
    end
  end

  test "#model returns the model class the repository manages" do
    assert_equal Author, author_repository.model
  end

  test "#routes returns an instance of the routes helper" do
    assert_instance_of Uchi::Repository::Routes, author_repository.routes
  end

  test "#searchable? returns true if the repository has searchable fields" do
    assert author_repository.searchable?
  end

  test "#title returns a string representation of the record" do
    author = Author.new(name: "Alice")

    assert_equal "Alice", author_repository.title(author)
  end

  test "#translate returns the translate helper" do
    assert_instance_of Uchi::Repository::Translate, author_repository.translate
  end

  private

  def author_repository
    Uchi::Repositories::Author.new
  end
end
