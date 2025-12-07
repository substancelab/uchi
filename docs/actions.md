# Actions

Uchi Actions allows your users to perform custom tasks on your records. For example you could add an action that bans a user, marks a received comment as spam, or resends a welcome email.

Actions are basically classes that inherit from `Uchi::Action` and define a `#perform` method. For example, to create a simple action that calls `touch` on a given record, add a file in app/uchi/actions/touch.rb:

```ruby
module Uchi
  module Actions
    class SendWelcomeEmail < Uchi::Action
      def perform(records, params)
        records.find_each do |record|
          UserMailer.welcome_email(record).deliver_later
        end
      end
    end
  end
end
```

## Responses

The default response after performing an action is to redirect to the page where the action was performed. To customize the behavior you can return an explicit Uchi::ActionResponse from the action:

```ruby
if things_went_well?
  ActionResponse.success("Done")
else
  ActionResponse.failure("Nope")
end
```

If you want to redirect the user somewhere else, chain a `redirect` to the response:

```ruby
ActionResponse.success("Done").redirect_to("/some/other/url")
```

## Attaching actions to repositories

Each repository has an `#actions` method that returns an `Array` of actions available to records in that repository. To attach an action to a resource, return their class in the `#actions` method:

```ruby
module Uchi
  module Repositories
    class Office < Repository
      def actions
        [
          Uchi::Actions::SendWelcomeEmail.new,
        ]
      end
    end
  end
end
```
