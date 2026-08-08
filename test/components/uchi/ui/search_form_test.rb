require "test_helper"

module Uchi
  module Ui
    class SearchFormTest < ViewComponent::TestCase
      test "renders a search form when at least one repository is searchable" do
        render_inline(SearchForm.new)

        assert_selector("form[method='get']")
        assert_selector("input[name='query']")
      end

      test "renders nothing when no repository is searchable" do
        with_repositories([]) do
          render_inline(SearchForm.new)
        end

        assert_no_selector("form")
      end

      private

      def with_repositories(repositories)
        original = Uchi::Repository.method(:all)
        Uchi::Repository.define_singleton_method(:all) { repositories }
        yield
      ensure
        Uchi::Repository.define_singleton_method(:all, original)
      end
    end
  end
end
