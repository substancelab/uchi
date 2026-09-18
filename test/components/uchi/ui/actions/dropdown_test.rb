require "test_helper"

class DropdownTestAction < Uchi::Action
  def perform(records, input = {})
    Uchi::ActionResponse.success
  end

  def render(record:, view:)
    view.link_to(name, "#")
  end

  def button_render(record:, view:)
    view.link_to(name, "#", class: Uchi::Flowbite::Button.classes)
  end
end

module Uchi
  module Ui
    module Actions
      class DropdownTest < ViewComponent::TestCase
        setup do
          @repository = Uchi::Repositories::Author.new
        end

        test "renders the single action directly, without a dropdown, when there's only one" do
          render_inline(Dropdown.new(actions: [DropdownTestAction.new], repository: @repository))

          assert_no_selector("[data-controller='dropdown']")
          assert_selector("a.bg-brand[href='#']")
        end

        test "renders a dropdown menu when there are multiple actions" do
          render_inline(Dropdown.new(actions: [DropdownTestAction.new, DropdownTestAction.new], repository: @repository))

          assert_selector("[data-controller='dropdown']")
          assert_selector("li[role='menuitem']", count: 2)
        end

        test "renders nothing when there are no actions" do
          render_inline(Dropdown.new(actions: [], repository: @repository))

          assert_no_selector("a")
          assert_no_selector("[data-controller='dropdown']")
        end
      end
    end
  end
end
