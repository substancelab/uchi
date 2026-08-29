# `Field::HasMany`

The `HasMany` association field wraps a `has_many` association on your model. By default it adds a list of associated records to the show page and on edit and new pages it renders a searchable dropdown field with checkboxes to select multiple options.

![HasMany field for a Project association filtered by "bi" input](https://res.cloudinary.com/substancelab/image/upload/v1767108606/uchi/docs/v1.0/has_many/filtered_light.png)

## How to add a HasMany field

To add the basic `HasMany` field to a repository, return it as part of the `#fields` method:

```ruby
def fields
  [
    Field::HasMany.new(:projects)
  ]
end
```

`HasMany` fields use the same searchable options as the associated repository. This also means that if the repository has no searchable fields, the filter input doesn't work.

## `#collection_query`

The chainable `#collection_query` method lets you control what records are included in the dropdown. It accepts a lambda, which is called when the user opens the dropdown or changes the filter input. The lambda receives an `ActiveRecord::Relation` with all records matching the filter query.

```ruby
Field::HasMany.new(:projects)
  .collection_query(lambda { |query|
    query.some_scope
  })
```

## How to limit what records are returned

You can use [`#collection_query`](#collection_query) to limit what records are returned. Remember you have access to the currently logged-in user in `Current.user`.

For example, if your `User` model has a `projects` method that returns the `Project` records the current user is allowed to access, you could do something like:

```ruby
Field::HasMany.new(:projects)
  .collection_query(lambda { |query|
    query.where(id: Current.user.projects)
  })
```

## How to control the order of records in dropdowns

When opening the record selector of a HasMany field the records are returned in the default order defined by the repository. To do something else, pass a lambda to the [`#collection_query`](#collection_query) method:

```ruby
Field::HasMany.new(:projects)
  .collection_query(lambda { |query|
    query.reorder(budget: :desc) }
  )
```

The lambda receives an `ActiveRecord::Relation` with all records returned from the repository. Note that you might have to use `#reorder`, not just `#order`, since the relation may already have an order defined.

## How to change titles in the dropdown

The dropdown displays the `title` of the record. For example, a `Person` repository may use the `name` attribute as its title. To customize the title for a record, implement `Repository#title`, see [repositories documentation](repositories/#customizing-the-title-of-a-record) for details.

## `#nested_fields`

By default, a `HasMany` field lets users pick from *existing* associated records. The chainable `#nested_fields` method switches it into an inline editor instead: it creates, edits, and deletes associated records directly within the parent form.

Your model must use `accepts_nested_attributes_for` for this to work:

```ruby
class Book < ApplicationRecord
  has_many :titles
  accepts_nested_attributes_for :titles, allow_destroy: true
end
```

Configure `#nested_fields` with the fields you want to edit for each associated record:

```ruby
module Uchi
  module Repositories
    class Book < Repository
      def fields
        [
          Field::String.new(:original_title),
          Field::HasMany.new(:titles).nested_fields(
            Field::String.new(:title),
            Field::String.new(:locale)
          )
        ]
      end
    end
  end
end
```

This also accepts an array:

```ruby
Field::HasMany.new(:titles).nested_fields([
  Field::String.new(:title),
  Field::String.new(:locale)
])
```

Once `#nested_fields` is configured, the field switches its rendering on both the edit and the show pages: the show page lists each associated record's configured fields inline instead of loading a scoped index view in a turbo-frame, and the edit/new pages render an inline editor instead of the searchable dropdown. `#collection_query` has no effect when `#nested_fields` is configured.

### Supported nested field types

- `String` - single-line text
- `Text` - multi-line text
- `Number` - integers, decimals
- `Boolean` - checkboxes
- `Date` - date picker
- `DateTime` - datetime picker

### Advanced model options

**Reject blank records** to avoid creating empty associated records:

```ruby
class Book < ApplicationRecord
  accepts_nested_attributes_for :titles,
    allow_destroy: true,
    reject_if: :all_blank
end
```

**Limit nested records** to prevent abuse:

```ruby
accepts_nested_attributes_for :titles,
  allow_destroy: true,
  limit: 10
```

Read more in [Rails' NestedAttributes](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html) documentation.
