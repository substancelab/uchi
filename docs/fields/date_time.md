# `Field::DateTime`

Renders a date and time picker for editing.

![DateTime field showing a date and time picker on an edit page](/fields/images/date_time_edit.png)
![DateTime field showing a formatted timestamp on a show page](/fields/images/date_time_show.png)

```ruby
Field::DateTime.new(:published_at)
```

## Search

Not searchable by default. If enabled, matches by equality; the search term must parse as a date/time (e.g. `2024-01-01 12:00`).
