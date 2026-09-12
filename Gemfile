# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in uchi.gemspec.
gemspec

gem "irb"
gem "ostruct"
gem "rake", "~> 13.0"

gem "capybara"
gem "standard", "~> 1.56"

# Stuff for running the tests and the dummy app
gem "rails-controller-testing"
gem "sqlite3"

# Additional database adapters used to run the test suite against MySQL and
# PostgreSQL in CI. Grouped so jobs that don't run the test suite (e.g. lint)
# can skip installing them and avoid building their native extensions.
group :test_databases do
  gem "mysql2"
  gem "pg"
end

# Documentation dependencies
gem "docyard"
