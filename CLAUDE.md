# Uchi

## Coding style

- User interface text should be looked up in the localization file, en.yml, before ultimately falling back to a hardcoded, english value.
- Use keyword arguments for any method accepting more than one argument.
- Sort methods alphabetically. Sort keywords alphabetically where possible. Sort HTML attributes alphabetically.

## Instructions for Claude

- Make sure all code quality checks pass by running `bundle exec rake default`.
