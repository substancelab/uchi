require "test_helper"

class UchiI18nTest < ActiveSupport::TestCase
  test "translate method delegates to I18n with uchi scope" do
    # This should not raise an error
    result = Uchi::I18n.translate("test_key", default: "fallback")
    assert_equal "fallback", result
  end

  test "translate method accepts custom scope" do
    result = Uchi::I18n.translate("test_key", scope: "custom", default: "fallback")
    assert_equal "fallback", result
  end

  test "module responds to translate" do
    assert Uchi::I18n.respond_to?(:translate)
  end
end
