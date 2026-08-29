require "test_helper"
require "ostruct"

require_relative "../dummy/app/uchi/repositories/author"

class UchiRepositoryTest < ActiveSupport::TestCase
  test ".all returns all Uchi::Repository's" do
    repositories = Uchi::Repository.all

    assert_equal \
      repositories.sort_by(&:name),
      [Uchi::Repositories::Author, Uchi::Repositories::Book, Uchi::Repositories::Company, Uchi::Repositories::Person, Uchi::Repositories::Title]
  end

  test ".for_model returns the repository for the given model" do
    assert_equal Uchi::Repositories::Author, Uchi::Repository.for_model(Author)
    assert_equal Uchi::Repositories::Author, Uchi::Repository.for_model("Author")
    assert_equal Uchi::Repositories::Author, Uchi::Repository.for_model(:Author)
  end

  test ".model returns the model class the repository manages" do
    assert_equal Author, Uchi::Repositories::Author.model
  end

  test ".any_searchable? returns true if at least one repository has a searchable field" do
    assert Uchi::Repository.any_searchable?
  end

  test ".any_searchable? returns false if no repository has a searchable field" do
    unsearchable_repository = Class.new(Uchi::Repository) do
      define_singleton_method(:model) { Author }
      define_method(:fields) { [Uchi::Field::Number.new(:id)] }
    end

    with_repositories([unsearchable_repository]) do
      assert_not Uchi::Repository.any_searchable?
    end
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
    assert_equal :id, sort_order.column
    assert_equal :asc, sort_order.direction
  end

  test "#fields_for_edit returns fields to include on the edit page" do
    fields = author_repository.fields_for_edit(record: Author.new)

    assert_equal [:name, :born_on, :biography], fields.map(&:name)
  end

  test "#fields_for_edit excludes fields where visible returns false for the record" do
    always_visible = Uchi::Field::String.new(:name)
    conditionally_visible = Uchi::Field::String.new(:secret).visible(->(record) { record.admin })

    repository = visibility_repository(always_visible, conditionally_visible)

    assert_equal [:name], repository.fields_for_edit(record: OpenStruct.new(admin: false)).map(&:name)
    assert_equal [:name, :secret], repository.fields_for_edit(record: OpenStruct.new(admin: true)).map(&:name)
  end

  test "#fields_for_new excludes fields where visible returns false for the record" do
    always_visible = Uchi::Field::String.new(:name)
    conditionally_visible = Uchi::Field::String.new(:secret).visible(->(record) { record.admin })

    repository = visibility_repository(always_visible, conditionally_visible)

    assert_equal [:name], repository.fields_for_new(record: OpenStruct.new(admin: false)).map(&:name)
    assert_equal [:name, :secret], repository.fields_for_new(record: OpenStruct.new(admin: true)).map(&:name)
  end

  test "#fields_for_show excludes fields where visible returns false for the record" do
    always_visible = Uchi::Field::String.new(:name)
    conditionally_visible = Uchi::Field::String.new(:secret).visible(->(record) { record.admin })

    repository = visibility_repository(always_visible, conditionally_visible)

    assert_equal [:name], repository.fields_for_show(record: OpenStruct.new(admin: false)).map(&:name)
    assert_equal [:name, :secret], repository.fields_for_show(record: OpenStruct.new(admin: true)).map(&:name)
  end

  test "#fields_for_index returns fields to include on the index page" do
    fields = author_repository.fields_for_index

    assert_equal [:id, :name, :born_on], fields.map(&:name)
  end

  test "#fields_for_show returns fields to include on the show page" do
    fields = author_repository.fields_for_show(record: Author.new)

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

  test "#find_all ignores a whitespace-only search query" do
    alice = Author.create!(name: "Alice")
    bob = Author.create!(name: "Bob")

    authors = author_repository.find_all(search: "   ")

    assert_equal [alice, bob], authors
  end

  test "#find_all applies a search query if given" do
    alice = Author.create!(name: "Alice")
    _bob = Author.create!(name: "Bob")

    authors = author_repository.find_all(search: "IC")

    assert_equal [alice], authors
  end

  test "#find_all applies a search query using a lambda field on a plain attribute" do
    alice = Author.create!(name: "Alice")
    _bob = Author.create!(name: "Bob")
    repository = Class.new(Uchi::Repository) do
      define_singleton_method(:model) { Author }
      define_method(:fields) {
        [
          Uchi::Field::String.new(:name).searchable(lambda { |query, term|
            query.where("name LIKE ?", "%#{term}%")
          })
        ]
      }
    end.new

    authors = repository.find_all(search: "IC")

    assert_equal [alice], authors
  end

  test "#find_all combines results from two lambda fields on plain attributes via OR" do
    alice = Author.create!(name: "Alice", biography: "Nothing relevant")
    bob = Author.create!(name: "Someone else", biography: "Bob's story")
    _carol = Author.create!(name: "Carol", biography: "Not mentioned")
    repository = Class.new(Uchi::Repository) do
      define_singleton_method(:model) { Author }
      define_method(:fields) {
        [
          Uchi::Field::String.new(:name).searchable(lambda { |query, term|
            query.where("name LIKE ?", "%#{term}%")
          }),
          Uchi::Field::Text.new(:biography).searchable(lambda { |query, term|
            query.where("biography LIKE ?", "%#{term}%")
          })
        ]
      }
    end.new

    authors = repository.find_all(search: "Alice")
    assert_equal [alice], authors

    authors = repository.find_all(search: "Bob")
    assert_equal [bob], authors
  end

  test "#find_all applies a search query using a lambda field, joining the association automatically" do
    company = Company.create!(name: "Acme")
    other_company = Company.create!(name: "Widgets Inc")
    alice = Person.create!(name: "Alice")
    bob = Person.create!(name: "Bob")
    Role.create!(person: alice, company: company)
    Role.create!(person: bob, company: other_company)

    people = searchable_companies_person_repository.find_all(search: "Acme")

    assert_equal [alice], people
  end

  test "#find_all applies a search query using a lambda field within the given scope" do
    company = Company.create!(name: "Acme")
    alice = Person.create!(name: "Alice")
    bob = Person.create!(name: "Bob")
    Role.create!(person: alice, company: company)
    Role.create!(person: bob, company: company)

    people = searchable_companies_person_repository.find_all(scope: Person.where(id: alice.id), search: "Acme")

    assert_equal [alice], people
  end

  test "#find_all combines results from lambda and plain searchable fields" do
    company = Company.create!(name: "Acme")
    alice = Person.create!(name: "Alice")
    bob = Person.create!(name: "Bob Acme")
    carol = Person.create!(name: "Carol")
    Role.create!(person: alice, company: company)

    people = searchable_companies_person_repository.find_all(search: "Acme")

    assert_equal [alice, bob].sort_by(&:id), people.sort_by(&:id)
    assert_not_includes people, carol
  end

  test "#find_all applies a sort order if given" do
    alice = Author.create!(name: "Alice")
    bob = Author.create!(name: "Bob")

    authors = author_repository.find_all(sort_order: Uchi::SortOrder.new(:name, :desc))

    assert_equal [bob, alice], authors
  end

  test "#find_all sorts by has_many association count ascending" do
    book_two = Book.create!(original_title: "Two Titles")
    book_zero = Book.create!(original_title: "Zero Titles")
    book_one = Book.create!(original_title: "One Title")
    Title.create!(book: book_two, title: "A")
    Title.create!(book: book_two, title: "B")
    Title.create!(book: book_one, title: "C")

    books = book_repository.find_all(sort_order: Uchi::SortOrder.new(:titles, :asc))

    assert_equal [book_zero, book_one, book_two], books
  end

  test "#find_all sorts by has_many association count descending" do
    book_two = Book.create!(original_title: "Two Titles")
    book_zero = Book.create!(original_title: "Zero Titles")
    book_one = Book.create!(original_title: "One Title")
    Title.create!(book: book_two, title: "A")
    Title.create!(book: book_two, title: "B")
    Title.create!(book: book_one, title: "C")

    books = book_repository.find_all(sort_order: Uchi::SortOrder.new(:titles, :desc))

    assert_equal [book_two, book_one, book_zero], books
  end

  test "#find_all sorts by has_and_belongs_to_many association count ascending" do
    author_two = Author.create!(name: "Two Books")
    author_zero = Author.create!(name: "Zero Books")
    author_one = Author.create!(name: "One Book")
    book_a = Book.create!(original_title: "Book A")
    book_b = Book.create!(original_title: "Book B")
    author_two.books = [book_a, book_b]
    author_one.books = [book_a]

    authors = habtm_author_repository.find_all(sort_order: Uchi::SortOrder.new(:books, :asc))

    assert_equal [author_zero, author_one, author_two], authors
  end

  test "#find_all sorts by has_and_belongs_to_many association count descending" do
    author_two = Author.create!(name: "Two Books")
    author_zero = Author.create!(name: "Zero Books")
    author_one = Author.create!(name: "One Book")
    book_a = Book.create!(original_title: "Book A")
    book_b = Book.create!(original_title: "Book B")
    author_two.books = [book_a, book_b]
    author_one.books = [book_a]

    authors = habtm_author_repository.find_all(sort_order: Uchi::SortOrder.new(:books, :desc))

    assert_equal [author_two, author_one, author_zero], authors
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

  test "#title returns the name attribute if available" do
    author = Author.new(name: "Alice")

    assert_equal "Alice", author_repository.title(author)
  end

  test "#title returns the title attribute if available" do
    title = Title.new(title: "Alice in Wonderland")

    assert_equal "Alice in Wonderland", title_repository.title(title)
  end

  test "#title returns whatever the repository has configured" do
    book = Book.new(original_title: "Original Title")

    assert_equal "Original Title", book_repository.title(book)
  end

  test "#title returns nil when record is nil" do
    assert_nil author_repository.title(nil)
  end

  test "#translate returns the translate helper" do
    assert_instance_of Uchi::Repository::Translate, author_repository.translate
  end

  private

  def author_repository
    Uchi::Repositories::Author.new
  end

  def book_repository
    Uchi::Repositories::Book.new
  end

  def title_repository
    Uchi::Repositories::Title.new
  end

  def searchable_companies_person_repository
    Class.new(Uchi::Repository) do
      define_singleton_method(:model) { Person }
      define_method(:fields) {
        [
          Uchi::Field::String.new(:name),
          Uchi::Field::HasMany.new(:companies).searchable(lambda { |query, term|
            query.where("companies.name LIKE ?", "%#{term}%")
          })
        ]
      }
    end.new
  end

  def habtm_author_repository
    Class.new(Uchi::Repository) do
      define_singleton_method(:model) { Author }
      define_method(:fields) { [Uchi::Field::HasAndBelongsToMany.new(:books)] }
    end.new
  end

  def visibility_repository(*fields)
    Class.new(Uchi::Repository) do
      define_method(:fields) { fields }
    end.new
  end

  def with_repositories(repositories)
    original = Uchi::Repository.method(:all)
    Uchi::Repository.define_singleton_method(:all) { repositories }
    yield
  ensure
    Uchi::Repository.define_singleton_method(:all, original)
  end
end
