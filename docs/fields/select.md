# `Field::Select`


The `Select` field renders a dropdown letting users pick a value from a fixed set of options. On display pages it shows the label for the record's current value.

![Select field showing a dropdown on an edit page](/fields/images/select_edit.png)

Values are matched against option keys by their string representation, so e.g. a persisted string of `"fiction"` matches an option keyed by the symbol `:fiction` - the same way a `<select>` element matches its options against the persisted attribute value.

## How to add a Select field

Add a `Select` field to a repository's `#fields` method, configuring the available options with `#options`:

```ruby
def fields
  [
    Field::Select.new(:size).options({
      "s" => "Small",
      "m" => "Medium",
      "l" => "Large"
    })
  ]
end
```

`#options` accepts a hash mapping the values stored on the record to the labels shown to users.

If the values and labels are the same, pass an array instead:

```ruby
Field::Select.new(:size).options(["Small", "Medium", "Large"])
```

To compute the options dynamically, pass a lambda. It's called with no arguments and should return a hash or an array as described above:

```ruby
Field::Select.new(:size).options(-> { Size.pluck(:key, :name).to_h })
```

## Grouped options

To group options under labeled optgroups, pass a hash whose values are themselves a hash or array of options, keyed by the group label:

```ruby
Field::Select.new(:size).options({
  "Letters" => {s: "Small", m: "Medium", l: "Large"},
  "Numbers" => ["32", "34", "36"]
})
```
