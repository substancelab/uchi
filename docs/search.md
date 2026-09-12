# Search

Uchi offers search across your repositories and fields out of the box.

Search is configured on a field-by-field basis. If a repository contains at least one searchable `Field`, a search field appears on the index page, and a global search page is enabled.

The search is fairly naive and is a bunch of conditions strung together by `OR`: `LIKE '%term%'` for text-based fields, equality for everything else. This can be modified by passing lambdas to `searchable` for the given field.

## Global search

Global search is accessible via the search icon in the navigation. It searches across all repositories with at least one searchable field.

## Disable search

By default all text-based fields are considered searchable. To toggle searchability for a field use the `searchable` method:

```ruby
Field::String.new(:password).searchable(false)
```

## Enable search

You can also enable search for fields that don't enable it by default:

```ruby
Field::Number.new(:id).searchable(true)
```

For text-based fields (`string`, `text`) Uchi performs a partial match using `LIKE` (`ILIKE` in PostgreSQL). For every other field type, the search term is cast to the field's type and matched by equality; if the term can't be cast (e.g. `"abc"` against an `:id`), the field is skipped.

## Customize search

By default the search is performed using `LIKE`/equality as described above. To customize how a field is searched, pass a lambda to the `searchable` method instead of `true`/`false`:

```ruby
Field::String.new(:number).searchable(lambda { |context:, query:, term:|
  # Remove space characters before searching
  term = term.tr(" ", "")
  query.where("REPLACE(number, ' ', '') LIKE ?", "%#{term}%")
})
```

The lambda receives the following arguments:

1. `context`: The [`Uchi::Context`](/context) we're currently processing.
2. `query`: The `ActiveRecord::Relation` that makes up the current database query
3. `term`: The search term entered by the user

The lambda should return an `ActiveRecord::Relation` matching the records for that term. Results from lambda-based searchable fields are combined with results from other searchable fields on the repository.

## Search for columns in an associated table

The `searchable` lambda isn't limited to the field's own attributes — it can also search by columns in other tables/models. If you have an `Employee` model that `belongs_to :company` and you want to find `Employee` records by querying for the `Company` name, you can configure the field like this:

```ruby
Field::BelongsTo.new(:company).searchable(lambda { |query:, term:|
  query.joins(:company).where("companies.name LIKE ?", "%#{term}%")
})
```
