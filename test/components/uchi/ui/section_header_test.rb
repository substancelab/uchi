require "test_helper"

module Uchi
  module Ui
    class SectionHeaderTest < ViewComponent::TestCase
      test "renders the title in a heading" do
        render_inline(SectionHeader.new(title: "Books"))

        assert_selector(
          "h2.text-2xl.font-semibold.tracking-tight.text-heading",
          text: "Books"
        )
      end

      test "does not wrap the heading in a flex row when no actions are given" do
        render_inline(SectionHeader.new(title: "Books"))

        assert_no_selector(".flex")
      end

      test "renders a single action in the outer flex row alongside the title" do
        render_inline(SectionHeader.new(title: "Books")) do |section_header|
          section_header.with_action { "<button>Add</button>".html_safe }
        end

        assert_selector(".flex.items-center.justify-between > h2", text: "Books")
        assert_selector(".flex.items-center.justify-between button", text: "Add")
      end

      test "renders multiple actions in the outer flex row" do
        render_inline(SectionHeader.new(title: "Books")) do |section_header|
          section_header.with_action { "<button>Add</button>".html_safe }
          section_header.with_action { "<button>Export</button>".html_safe }
        end

        assert_selector(".flex.items-center.justify-between > h2", text: "Books")
        assert_selector(".flex.items-center.justify-between button", text: "Add")
        assert_selector(".flex.items-center.justify-between button", text: "Export")
      end
    end
  end
end
