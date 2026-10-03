# `Field::Id`

A simple field that's tailored for `id` attributes. It renders whatever the id is and links to the show page for the record.

![Id field showing a linked id value on a show page](/fields/images/id_show.png)

```ruby
Field::Id.new(:id)
```

## Search

Searchable by default. Matches by equality; the search term must be a valid number.
