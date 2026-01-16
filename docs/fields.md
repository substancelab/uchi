# Fields

## Only show a field on specific pages

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

## Search

If a repository contains at least one searchable `Field` a search field appears on the index page. By default all text-based fields are considered searchable.

The search is fairly naive and is a bunch of `LIKE '%query%'` (`ILIKE` in PostgreSQL) clauses strung together by `OR`.

### Disable search

To toggle searchability for a field use the `:searchable` option:

```ruby
Field::String.new(:password).searchable(false)
```

### Enable search

You can also enable search for fields that don't enable it by default:

```ruby
Field::Number.new(:id).searchable(true)
```

Uchi casts whatever datatype the field uses into a string when searching and perform a partial match on it using `LIKE` (`ILIKE` in PostgreSQL), which may or may not yield the results you expect.


## Sorting

All fields are considered sortable by default. This means that a link to toggle the order of a column appears for all columns on index pages. How to sort a specific field - or to disable it entirely - is configured using the `:sortable` option.

### Disable sorting

To disable sorting a specific field:

```ruby
Field::Number.new(:calculated_sum).sortable(false)
```

### Customize sorting

To customize the query used to sort by a given field, pass a lambda to the `sortable` method:

```ruby
Field::Number.new(:users_count).sortable(lambda { |query, direction|
  query.joins(:users).group(:id).order("COUNT(users.id) #{direction}")
})
```

The lambda receives 2 arguments:

1. `query`: The `ActiveRecord::Relation` that makes up the current database query
2. `direction`: A symbol indicating what order to sort; either `:asc` or `:desc`.

The lambda should return an `ActiveRecord::Relation` with the desired sort order added.

### Sorting by columns in another table

Thanks to ActiveRecord we can even sort by columns in other tables/models. If you have an `Employee` model that belongs to a `Company` and you want to allow your users to sort the employee list by company name, you can configure the field like this:

```ruby
Field::BelongsTo.new(:company).sortable(lambda { |query, direction|
  query.joins(:office).order(:offices => {:name => direction})
})
```

## Field::BelongsTo

![BelongsTo field for a Person association filtered by "be" input](https://res.cloudinary.com/substancelab/image/upload/v1767091341/uchi/docs/v1.0/belongs_to/filtered_light.png)

The `BelongsTo` association field wraps a `belongs_to` association on your model. By default it shows a link to the associated record on display pages and on edit and new pages it renders a searchable dropdown field.

### How to add a BelongsTo field

To add the basic `BelongsTo` field to a repository, return it as part of the `#fields` method:

```ruby
def fields
  [
    Field::BelongsTo.new(:person)
  ]
end
```

`BelongsTo` fields use the same searchable options as the associated repository. This also means that if the repository has no searchable fields, the filter input doesn't work.

### `#collection_query`

The chainable `#collection_query` method lets you control what records are included in the dropdown. It accepts a lambda, which is called when the user opens the dropdown or changes the filter input. The lambda receives an `ActiveRecord::Relation` with all records matching the filter query.

```ruby
Field::BelongsTo.new(:person)
  .collection_query(lambda { |query|
    query.some_scope
  })
```

### How to limit what records are returned

You can use [`#collection_query`](#collection_query) to limit what records are returned. Remember you have access to the currently logged-in user in `Current.user`.

For example, if your `User` model has an `authorized_people` method that returns the people records the current user is allowed to access, you could do something like:

```ruby
Field::BelongsTo.new(:person)
  .collection_query(lambda { |query|
    query.where(id: Current.user.authorized_people)
  })
```

### How to control the order of records in dropdowns

When opening the record selector of a BelongsTo field the records are returned in the default order defined by the repository. To do something else, pass a lambda to the [`#collection_query`](#collection_query) method:

```ruby
Field::BelongsTo.new(:person)
  .collection_query(lambda { |query|
    query.reorder(:first_name, :last_names) }
  )
```

The lambda receives an `ActiveRecord::Relation` with all records returned from the repository. Note that you might have to use `#reorder`, not just `#order`, since the relation may already have an order defined.

### How to change titles in the dropdown

The dropdown displays the `title` of the record. For example, a `Person` repository may use the `name` attribute as its title. To customize the title for a record, implement `Repository#title`, see [repositories documentation](repositories/#customizing-the-title-of-a-record) for details.

### BelongsTo field for polymorphic associations

Out of the box, `Field::BelongsTo` works for regular `belongs_to` associations as well as polymorphic ones. However, for polymorphic associations the field cannot be shown in forms (ie `edit` or `new` pages) since Uchi cannot guess what models to show in the associated record dropdown.

For now, the best workaround is to remove the `BelongsTo` field from those pages and add explicit fields for the polymorphic attributes instead, ie:

```ruby
def fields
  [
    Field::BelongsTo.new(:owner).on(:index, :show),
    Field::String.new(:owner_type).on(:edit, :new),
    Field::Number.new(:owner_id).on(:edit, :new),
  ]
end
```

or create a custom field that provides a user interface to select whatever models you want to choose between.

## Field::HasMany

![HasMany field for a Project association filtered by "bi" input](https://res.cloudinary.com/substancelab/image/upload/v1767108606/uchi/docs/v1.0/has_many/filtered_light.png)

The `HasMany` association field wraps a `has_many` association on your model. By default it adds a list of associated records to the show page and on edit and new pages it renders a searchable dropdown field with checkboxes to select multiple options.

### How to add a HasMany field

To add the basic `HasMany` field to a repository, return it as part of the `#fields` method:

```ruby
def fields
  [
    Field::HasMany.new(:projects)
  ]
end
```

`HasMany` fields use the same searchable options as the associated repository. This also means that if the repository has no searchable fields, the filter input doesn't work.

### `#collection_query`

The chainable `#collection_query` method lets you control what records are included in the dropdown. It accepts a lambda, which is called when the user opens the dropdown or changes the filter input. The lambda receives an `ActiveRecord::Relation` with all records matching the filter query.

```ruby
Field::HasMany.new(:projects)
  .collection_query(lambda { |query|
    query.some_scope
  })
```

### How to limit what records are returned

You can use [`#collection_query`](#collection_query) to limit what records are returned. Remember you have access to the currently logged-in user in `Current.user`.

For example, if your `User` model has a `projects` method that returns the `Project` records the current user is allowed to access, you could do something like:

```ruby
Field::HasMany.new(:projects)
  .collection_query(lambda { |query|
    query.where(id: Current.user.projects)
  })
```

### How to control the order of records in dropdowns

When opening the record selector of a HasMany field the records are returned in the default order defined by the repository. To do something else, pass a lambda to the [`#collection_query`](#collection_query) method:

```ruby
Field::HasMany.new(:projects)
  .collection_query(lambda { |query|
    query.reorder(budget: :desc) }
  )
```

The lambda receives an `ActiveRecord::Relation` with all records returned from the repository. Note that you might have to use `#reorder`, not just `#order`, since the relation may already have an order defined.

### How to change titles in the dropdown

The dropdown displays the `title` of the record. For example, a `Person` repository may use the `name` attribute as its title. To customize the title for a record, implement `Repository#title`, see [repositories documentation](repositories/#customizing-the-title-of-a-record) for details.
