# `Field::Date`

Renders a date picker for editing.

![Date field showing a date picker on an edit page](/fields/images/date_edit.png)
![Date field showing a formatted date on a show page](/fields/images/date_show.png)

```ruby
Field::Date.new(:published_on)
```

## Search

Not searchable by default. If enabled, matches by equality; the search term must parse as a date (e.g. `2024-01-01`).
