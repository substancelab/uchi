# `Field::BelongsTo`

The `BelongsTo` association field wraps a `belongs_to` association on your model. By default it shows a link to the associated record on display pages and on edit and new pages it renders a searchable dropdown field.

![BelongsTo field for a Person association filtered by "be" input](https://res.cloudinary.com/substancelab/image/upload/v1767091341/uchi/docs/v1.0/belongs_to/filtered_light.png)

## How to add a BelongsTo field

To add the basic `BelongsTo` field to a repository, return it as part of the `#fields` method:

```ruby
def fields
  [
    Field::BelongsTo.new(:person)
  ]
end
```

`BelongsTo` fields use the same searchable options as the associated repository. This also means that if the repository has no searchable fields, the filter input doesn't work.

## `#collection_query`

The chainable `#collection_query` method lets you control what records are included in the dropdown. It accepts a lambda, which is called when the user opens the dropdown or changes the filter input. The lambda receives an `ActiveRecord::Relation` with all records matching the filter query.

```ruby
Field::BelongsTo.new(:person)
  .collection_query(lambda { |query|
    query.some_scope
  })
```

## How to limit what records are returned

You can use [`#collection_query`](#collection_query) to limit what records are returned. Remember you have access to the currently logged-in user in `Current.user`.

For example, if your `User` model has an `authorized_people` method that returns the people records the current user is allowed to access, you could do something like:

```ruby
Field::BelongsTo.new(:person)
  .collection_query(lambda { |query|
    query.where(id: Current.user.authorized_people)
  })
```

## How to control the order of records in dropdowns

When opening the record selector of a BelongsTo field the records are returned in the default order defined by the repository. To do something else, pass a lambda to the [`#collection_query`](#collection_query) method:

```ruby
Field::BelongsTo.new(:person)
  .collection_query(lambda { |query|
    query.reorder(:first_name, :last_names) }
  )
```

The lambda receives an `ActiveRecord::Relation` with all records returned from the repository. Note that you might have to use `#reorder`, not just `#order`, since the relation may already have an order defined.

## How to change titles in the dropdown

The dropdown displays the `title` of the record. For example, a `Person` repository may use the `name` attribute as its title. To customize the title for a record, implement `Repository#title`, see [repositories documentation](repositories/#customizing-the-title-of-a-record) for details.

## BelongsTo field for polymorphic associations

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
