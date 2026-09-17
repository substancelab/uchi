require "test_helper"

class UchiViewConstantsTest < ActiveSupport::TestCase
  test "EDIT is the edit view" do
    assert_equal :edit, Uchi::View::EDIT.to_sym
  end

  test "INDEX is the index view" do
    assert_equal :index, Uchi::View::INDEX.to_sym
  end

  test "NEW is the new view" do
    assert_equal :new, Uchi::View::NEW.to_sym
  end

  test "SHOW is the show view" do
    assert_equal :show, Uchi::View::SHOW.to_sym
  end

  test "the view constants are frozen" do
    assert Uchi::View::EDIT.frozen?
    assert Uchi::View::INDEX.frozen?
    assert Uchi::View::NEW.frozen?
    assert Uchi::View::SHOW.frozen?
  end

  test "ALL contains every view" do
    assert_equal(
      [Uchi::View::EDIT, Uchi::View::INDEX, Uchi::View::NEW, Uchi::View::SHOW],
      Uchi::View::ALL
    )
  end

  test "ALL is frozen" do
    assert Uchi::View::ALL.frozen?
  end

  test "FORM contains only the edit and new views" do
    assert_equal [Uchi::View::EDIT, Uchi::View::NEW], Uchi::View::FORM
  end

  test "FORM is frozen" do
    assert Uchi::View::FORM.frozen?
  end
end
