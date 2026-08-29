# Search

Uchi offers search across your repositories and fields out of the box.

Search is configured on a field-by-field basis. If a repository contains at least one searchable `Field`, a search field appears on the index page, and a global search page is enabled.

The search is fairly naive and is a bunch of `LIKE '%query%'` (`ILIKE` in PostgreSQL) clauses strung together by `OR`, but this can be modified by passing lambdas to `searchable` for the given field.

## Global search

Global search is accessible via the search icon in the navigation. It searches across all repositories with at least one searchable field.

## Disable search

By default all text-based fields are considered searchable. To toggle searchability for a field use the `searchable` option:

```ruby
Field::String.new(:password).searchable(false)
```

## Enable search

You can also enable search for fields that don't enable it by default:

```ruby
Field::Number.new(:id).searchable(true)
```

Uchi casts whatever data type the field uses into a string when searching and performs a partial match on it using `LIKE` (`ILIKE` in PostgreSQL), which may or may not yield the results you expect.

## Customize search

By default the search is performed using a `LIKE` query on the attribute (`ILIKE` in PostgreSQL). To customize how a field is searched, pass a lambda to the `searchable` method instead of `true`/`false`:

```ruby
Field::String.new(:number).searchable(lambda { |query, term|
  # Remove space characters before searching
  term = term.tr(" ", "")
  query.where("REPLACE(number, ' ', '') LIKE ?", "%#{term}%")
})
```

The lambda receives 2 arguments:

1. `query`: The `ActiveRecord::Relation` that makes up the current database query
2. `term`: The search term entered by the user

The lambda should return an `ActiveRecord::Relation` matching the records for that term. Results from lambda-based searchable fields are combined with results from other searchable fields on the repository.

## Search for columns in an associated table

The `searchable` lambda isn't limited to the field's own attributes — it can also search by columns in other tables/models. If you have an `Employee` model that `belongs_to :company` and you want to find `Employee` records by querying for the `Company` name, you can configure the field like this:

```ruby
Field::BelongsTo.new(:company).searchable(lambda { |query, term|
  query.joins(:company).where("companies.name LIKE ?", "%#{term}%")
})
```
