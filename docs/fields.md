# Fields

## Only show a field on specific pages

Use the `on:` option to control what pages to show a field on. For example if your id field should only be visible on the index listing, you can configure it as

```ruby
Field::Number(:id, on: [:index])
```

Possible actions are

- `:index`
- `:show`
- `:new`
- `:edit`

The default is to show all fields on all pages.

## Search

If a repository contains at least one searchable `Field` a search field appears on the index page. By default all text-based fields are considered searchable.

The search is fairly naive and is a bunch of `LIKE '%query%'` (`ILIKE` in PostgreSQL) clauses strung together by `OR`.

### Disable search

To toggle searchability for a field use the `:searchable` option:

```ruby
Field::String.new(:password, searchable: false)
```

### Enable search

You can also enable search for fields that don't enable it by default:

```ruby
Field::Number.new(:id, searchable: true)
```

Uchi casts whatever datatype the field uses into a string when searching and perform a partial match on it using `LIKE` (`ILIKE` in PostgreSQL), which may or may not yield the results you expect.


## Sorting

All fields are considered sortable by default. This means that a link to toggle the order of a column appears for all columns on index pages. How to sort a specific field - or to disable it entirely - is configured using the `:sortable` option.

### Disable sorting

To disable sorting a specific field:

```ruby
Field::Number.new(:calculated_sum, sortable: false)
```

### Customize sorting

To customize the query used to sort by a given field, pass a lambda to `:sortable`:

```css
Field::Number(
  :users_count,
  sortable: lambda { |query, direction|
    query.joins(:users).group(:id).order("COUNT(users.id) #{direction}")
  }
)
```

The lambda receives 2 arguments:

1. `query`: The `ActiveRecord::Relation` that makes up the current database query
2. `direction`: A symbol indicating what order to sort; either `:asc` or `:desc`.

The lambda should return an `ActiveRecord::Relation` with the desired sort order added.

### Sorting by columns in another table

Thanks to ActiveRecord we can even sort by columns in other tables/models. If you have an `Employee` model that belongs to a `Company` and you want to allow your users to sort the employee list by company name, you can configure the field like this:

```ruby
Field::BelongsTo.new(
  :company,
  sortable: lambda { |query, direction|
    query.joins(:office).order(:offices => {:name => direction})
})
```
