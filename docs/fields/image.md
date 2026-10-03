# `Field::Image`

Lets users upload and view images.

![Image field showing an uploaded logo on a show page](/fields/images/image_show.png)

```ruby
Field::Image.new(:logo)
```

## Search

Not searchable by default. The field is an Active Storage attachment, not a column, so enabling it needs a `searchable` lambda - see [Customize search](/search#customize-search).
