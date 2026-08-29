# Fields

The `#fields` method of your [repository](/repositories) controls what fields you want to expose to your users, whether in the table on the index page, the overview on the show page, or the inputs on the edit or new pages.

```ruby
def fields
  [
    Field::Id.new(:id),
    Field::String.new(:name),
    Field::Image.new(:logo),
    Field::BelongsTo.new(:industry),
    Field::HasMany.new(:people)
  ]
end
```

## Field types

Uchi ships with a bunch of field types that you can use to build out your user interface. All fields support a set of customization methods that are chained together to provide the experience you want.

* [`Field::BelongsTo`](/fields/belongs_to)
* [`Field::Boolean`](/fields/boolean)
* [`Field::Date`](/fields/date)
* [`Field::DateTime`](/fields/date_time)
* [`Field::File`](/fields/file)
* [`Field::HasAndBelongsToMany`](/fields/has_and_belongs_to_many)
* [`Field::HasMany`](/fields/has_many)
* [`Field::Id`](/fields/id)
* [`Field::Image`](/fields/image)
* [`Field::Number`](/fields/number)
* [`Field::Select`](/fields/select)
* [`Field::String`](/fields/string)
* [`Field::Text`](/fields/text)

## Visibility

### Only show a field on specific pages

Use the `on` method to control what pages to show a field on. For example if your id field should only be visible on the index listing, you can configure it as

```ruby
Field::Number.new(:id).on(:index)
```

Possible actions are

- `:index`
- `:show`
- `:new`
- `:edit`

The default is to show all fields on all pages.

### Only show a field for specific records

Giving the field a `visible` lambda gives you more control over when to render a field.

```ruby
Field::Number.new(:discount).visible(->(record) { record.discountable? })
```

The lambda is passed the actual record and the field will be rendered if the lambda returns a truthy value.

Note that this is not usable for index pages. The index table header always shows all configured columns — since there's no single record to evaluate visibility against. To remove a column from the index page use `on([:edit, :new, :show])` instead.

## Search

If a repository contains at least one searchable `Field`, a search field appears on the index page. By default all text-based fields are considered searchable. See the [Search](/search) documentation for more details.

```ruby
Field::Text.new(:name).searchable(true)
```

## Sorting

When a `sortable` field appears on the index page, it gets a link to toggle the order of the records based on the field. How to sort a specific field - or to disable it entirely - is configured using the `sortable` method.

### Enable sorting

Most fields are sortable by default, but if you need to enable sortable for a given field you can set it to `true`:

```ruby
Field::String.new(:name).sortable(true)
```

### Customize sorting

To customize the query used to sort by a given field, pass a lambda to the `sortable` method:

```ruby
Field::String.new(:name).sortable(lambda { |query, direction|
  query.order(first_name: direction, last_names: direction)
})
```

The lambda receives 2 arguments:

1. `query`: The `ActiveRecord::Relation` that makes up the current database query
2. `direction`: A symbol indicating what order to sort; either `:asc` or `:desc`.

The lambda should return an `ActiveRecord::Relation` with the desired sort order added.

You can even use this to sort by computed columns via SQL:

```ruby
Field::Number.new(:users_count).sortable(lambda { |query, direction|
  query.joins(:users).group(:id).order("COUNT(users.id) #{direction}")
})
```

### Sorting by columns in another table

Thanks to ActiveRecord we can even sort by columns in other tables/models. If you have an `Employee` model that belongs to a `Company` and you want to allow your users to sort the employee list by company name, you can configure the field like this:

```ruby
Field::BelongsTo.new(:company).sortable(lambda { |query, direction|
  query.joins(:office).order(:offices => {:name => direction})
})
```

### Disable sorting

To disable sorting a specific field:

```ruby
Field::Number.new(:calculated_sum).sortable(false)
```
