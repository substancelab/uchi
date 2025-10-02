require "test_helper"

require "uchi/repository"

class UchiRepositoryTest < ActiveSupport::TestCase
  test "#controller_name returns stuff" do
    repository = Uchi::Repository.new
    assert_equal "stuff", repository.controller_name
  end
end
