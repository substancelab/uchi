# `Field::HasAndBelongsToMany`

The `HasAndBelongsToMany` field wraps a `has_and_belongs_to_many` association on your model. By default it adds a list of associated records to the show page and on edit and new pages it renders a checkbox list of available records.

![HasAndBelongsToMany field showing a checkbox list on an edit page](/fields/images/has_and_belongs_to_many_edit.png)

## How to add a HasAndBelongsToMany field

To add the basic `HasAndBelongsToMany` field to a repository, return it as part of the `#fields` method:

```ruby
def fields
  [
    Field::HasAndBelongsToMany.new(:tags)
  ]
end
```

## `#collection_query`

The chainable `#collection_query` method lets you control what records are available to pick from. It accepts a lambda, which receives an `ActiveRecord::Relation` with all records for the associated repository.

```ruby
Field::HasAndBelongsToMany.new(:tags)
  .collection_query(lambda { |query|
    query.some_scope
  })
```

## How to limit what records are returned

You can use [`#collection_query`](#collection_query) to limit what records are returned. Remember you have access to the currently logged-in user in `Current.user`.

```ruby
Field::HasAndBelongsToMany.new(:tags)
  .collection_query(lambda { |query|
    query.where(id: Current.user.tags)
  })
```

## Show page

Associated records are listed in a scoped index table below the record's other fields.

![HasAndBelongsToMany field showing an associated list of tags on a show page](/fields/images/has_and_belongs_to_many_show.png)

## How to change titles in the checkbox list

The checkbox list and show page display the `title` of each associated record. For example, a `Tag` repository may use the `name` attribute as its title. To customize the title for a record, implement `Repository#title`, see [repositories documentation](repositories/#customizing-the-title-of-a-record) for details.
