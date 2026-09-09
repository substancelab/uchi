# Views

The individual screens and pages Uchi renders are divided into a set of views:

- Edit
- Index
- New
- Show

These map cleanly to the actions (and views) you know from standard Rails CRUD controllers. In Uchi the views are shared across all repositories, meaning it's the same view template that renders the show page for all records.

In code these are represented as `Uchi::View` instances.

## Edit

The page where you edit the record in a repository.

```ruby
view.name #=> :edit
view.edit? #=> true
```

## Index

The homepage for each repository, listing the first page of records.

```ruby
view.name #=> :index
view.index? #=> true
```

## New

A page to add new records to a repository.

```ruby
view.name #=> :new
view.new? #=> true
```

## Show

A page dedicated to showing the details of a record.

```ruby
view.name #=> :show
view.show? #=> true
```
