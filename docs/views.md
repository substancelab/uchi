# Views

The individual screens and pages Uchi renders are divided into a set of views:

- Edit
- Index
- New
- Show

These map cleanly to the actions (and views) you know from standard Rails CRUD controllers. In Uchi the views are shared across all repositories, meaning it's the same view template that renders the show page for all records.

In code each view is represented as a `Uchi::View` instance. Each instance is available as a constant, e.g. `Uchi::View::NEW` etc.

You can use these when defining [field visibility](/fields#visibility):

```ruby
Field::Text.new(:slogan).on([Uchi::View::EDIT, Uchi::View::NEW])
```

## Edit

The page where you edit the record in a repository.

![Edit view](/views/images/view-edit.png)

```ruby
view = Uchi::View::EDIT
view.name #=> :edit
view.edit? #=> true
```

## Index

The homepage for each repository, listing the first page of records.

![Index view](/views/images/view-index.png)

```ruby
view = Uchi::View::INDEX
view.name #=> :index
view.index? #=> true
```

## New

A page to add new records to a repository.

![New view](/views/images/view-new.png)

```ruby
view = Uchi::View::NEW
view.name #=> :new
view.new? #=> true
```

## Show

A page dedicated to showing the details of a record.

![Show view](/views/images/view-show.png)

```ruby
view = Uchi::View::SHOW
view.name #=> :show
view.show? #=> true
```
