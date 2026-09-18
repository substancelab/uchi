# Actions

Uchi Actions allow your users to perform custom tasks on your records. For example you could add an action that bans a user, marks a received comment as spam, or resends a welcome email.

Actions are rendered in the header of the index, show, and edit pages. Depending on the view, they either apply to a single record (e.g. on the show and edit pages) or to the repository as a whole (e.g. on the index page, where there's no specific record yet).

## Using the default actions

Every repository comes with three actions out of the box, so you don't have to write any code to get basic CRUD functionality:

- `Uchi::Action::New` — links to the page for creating a new record. Visible on the `:index` view.
- `Uchi::Action::Edit` — links to the page for editing a record. Visible on the `:show` view.
- `Uchi::Action::Delete` — destroys a record, after asking for confirmation. Visible on the `:edit` view.

These are returned by the default `#actions` implementation on `Uchi::Repository`:

```ruby
def actions
  [
    Action::New.new,
    Action::Edit.new,
    Action::Delete.new
  ]
end
```

Since `#actions` is a regular method, you can override it in your own repository to remove one of the defaults, reorder them, or combine them with your own actions (see [Registering actions on a repository](#registering-actions-on-a-repository) below).

### Where an action appears

Each action has an `#on` configuration that determines which views it's visible on:

```ruby
Uchi::Action::Delete.new.on # => [Uchi::View::EDIT]
```

You can change this on a per-instance basis when registering the action:

```ruby
module Uchi
  module Repositories
    class Comment < Repository
      def actions
        super + [Uchi::Action::Delete.new.on(:show, :edit)]
      end
    end
  end
end
```

Only put record-bound actions like `Delete` on record views (`:show` and `:edit`) — not `:index`. The index page's header isn't rendered for a specific record (it's rendered with `record: nil`), and `Delete` needs a record to build its destroy link, so adding it to `:index` raises while rendering the page.

### Where actions render

Actions render in the header of the index, show, and edit pages. The first `#max_number_of_actions_outside_dropdown` actions (2 by default) render directly as standalone buttons; any remaining actions are tucked away in a dropdown menu instead, so the header doesn't get crowded as you register more actions.

To change how many actions are shown before the rest collapse into the dropdown, override `#max_number_of_actions_outside_dropdown` on your repository:

```ruby
module Uchi
  module Repositories
    class Comment < Repository
      def max_number_of_actions_outside_dropdown
        1
      end
    end
  end
end
```

## Registering actions for a repository

Each repository has an `#actions` method that returns an `Array` of actions available to records in that repository. To attach an action to a repository, return an instance of it from `#actions`:

```ruby
module Uchi
  module Repositories
    class Office < Repository
      def actions
        [
          Uchi::Actions::SendWelcomeEmail.new
        ]
      end
    end
  end
end
```

Overriding `#actions` replaces the default `New`/`Edit`/`Delete` actions entirely. If you want to keep them and add your own, call `super` and append to it:

```ruby
module Uchi
  module Repositories
    class Office < Repository
      def actions
        super + [Uchi::Actions::SendWelcomeEmail.new]
      end
    end
  end
end
```

## Creating your own actions

Actions are classes that inherit from `Uchi::Action` and define a `#perform` method. For example, to create a simple action that sends a welcome email, add a file in `app/uchi/actions/send_welcome_email.rb`:

```ruby
module Uchi
  module Actions
    class SendWelcomeEmail < Uchi::Action
      def perform(records, input = {})
        records.each do |record|
          UserMailer.welcome_email(record).deliver_later
        end

        Uchi::ActionResponse.success("Welcome email sent")
      end
    end
  end
end
```

`#perform` receives the records the action was triggered for. It's expected to return a `Uchi::ActionResponse`.

### Responses

The default response after performing an action is to redirect to the page where the action was performed. To customize the behavior you can return an explicit `Uchi::ActionResponse` from the action:

```ruby
if things_went_well?
  Uchi::ActionResponse.success("Done")
else
  Uchi::ActionResponse.error("Nope")
end
```

If you want to redirect the user somewhere else, chain a `redirect_to` onto the response:

```ruby
Uchi::ActionResponse.success("Done").redirect_to(path: "/some/other/url")
```

You can also trigger a file download:

```ruby
Uchi::ActionResponse.success("Exported").download(file_path: path, filename: "export.csv")
```

or render a Turbo Stream response:

```ruby
Uchi::ActionResponse.success.turbo_stream { turbo_stream.remove(record) }
```

### The repository and context

While an action is being rendered or performed, it has access to:

- `#repository` — the `Uchi::Repository` instance it's currently being used with.
- `#context` — the `Uchi::Context` the current request is running in.

Use these to build URLs, look up translations, or otherwise tailor the action to the repository it belongs to:

```ruby
def perform(records, input = {})
  Uchi::ActionResponse.success.redirect_to(path: repository.routes.path_for(:index))
end
```

### Naming and styling

By default, an action's display name is looked up from `uchi.action.[action_key].name`, and falls back to a humanized version of the class name (e.g. `SendWelcomeEmail` becomes "Send Welcome Email"). Override `#name` to customize it:

```ruby
def name
  "Send welcome email"
end
```

The built-in `New`, `Edit`, and `Delete` actions don't use this lookup — since their labels are already repository-specific (e.g. "New author", "Delete comment"), they instead use the repository's own translations, such as `repository.translate.link_to_new`. See [Translations](/translations) for how to customize those.

Use `#style` to control the action's visual style (e.g. `:default` or `:danger`):

```ruby
def style
  :danger
end
```

### Customizing how an action renders

By default, actions render as a button that submits a POST request to execute the action (calling `#perform`). Some actions instead need to render as a plain link — `Uchi::Action::Edit` and `Uchi::Action::New`, for instance, link straight to a page instead of executing anything. To customize this, override:

- `#render_as_dropdown_item(record:, view:)` — how the action renders as an item inside the actions dropdown menu.
- `#render_as_button(record:, view:)` — how the action renders as a standalone button/link, for when it's the only action available.

```ruby
module Uchi
  module Actions
    class ViewOnSite < Uchi::Action
      def render_as_dropdown_item(record:, view:)
        view.link_to(name, record.public_url, class: "block p-2")
      end

      def render_as_button(record:, view:)
        view.link_to(name, record.public_url, class: Uchi::Flowbite::Button.classes(style: style))
      end
    end
  end
end
```
