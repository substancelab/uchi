require "test_helper"

module Uchi
  module Ui
    class SearchInputTest < ViewComponent::TestCase
      test "renders a labelled search field" do
        render_inline(SearchInput.new(label: "Search books"))

        assert_selector("label.sr-only", text: "Search books")
        assert_selector("input[type='search'][name='query'][placeholder='Search books']")
      end

      test "defaults the label to the translated search label" do
        render_inline(SearchInput.new)

        assert_selector("label.sr-only", text: "Search")
      end

      test "renders the current query as the field value" do
        render_inline(SearchInput.new(query: "Hobbit"))

        assert_selector("input[name='query'][value='Hobbit']")
      end

      test "renders a submit button" do
        render_inline(SearchInput.new(label: "Search books"))

        assert_selector("button[type='submit']")
        assert_selector("button .sr-only", text: "Search books")
      end
    end
  end
end
