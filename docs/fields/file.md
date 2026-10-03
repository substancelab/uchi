# `Field::File`

Lets users upload and download files. Unlike most fields, `File` is not searchable or sortable by default.

![File field showing a file input on an edit page](/fields/images/file_edit.png)
![File field showing a download link on a show page](/fields/images/file_show.png)

```ruby
Field::File.new(:attachment)
```

## Search

Not searchable by default. The field is an Active Storage attachment, not a column, so enabling it needs a `searchable` lambda - see [Customize search](/search#customize-search).
