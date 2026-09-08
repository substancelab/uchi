# frozen_string_literal: true

require "test_helper"

class UchiCallWithFlexibleArgumentsTest < ActiveSupport::TestCase
  test "#call passes matching keyword arguments to the proc" do
    proc = ->(name:) { "hi #{name}" }

    result = Uchi::CallWithFlexibleArguments.new(proc).call(name: "world")

    assert_equal "hi world", result
  end

  test "#call ignores keyword arguments not declared by the proc" do
    proc = ->(name:) { "hi #{name}" }

    result = Uchi::CallWithFlexibleArguments.new(proc).call(name: "world", extra: "ignored")

    assert_equal "hi world", result
  end

  test "#call passes only the subset of declared keyword arguments" do
    proc = ->(first:, second:) { [first, second] }

    result = Uchi::CallWithFlexibleArguments.new(proc).call(
      first: "a",
      second: "b",
      third: "c"
    )

    assert_equal %w[a b], result
  end

  test "#call raises ArgumentError when a declared keyword argument is missing" do
    proc = ->(name:) { "hi #{name}" }

    error = assert_raises(ArgumentError) do
      Uchi::CallWithFlexibleArguments.new(proc).call(other: "value")
    end

    assert_match(/name/, error.message)
  end

  test "#call works with a proc that declares no parameters" do
    proc = -> { "no args" }

    result = Uchi::CallWithFlexibleArguments.new(proc).call(name: "ignored")

    assert_equal "no args", result
  end

  test "#call works when called without any keyword arguments" do
    proc = -> { "no args" }

    result = Uchi::CallWithFlexibleArguments.new(proc).call

    assert_equal "no args", result
  end

  test "#proc returns the wrapped proc" do
    proc = ->(name:) { name }

    call = Uchi::CallWithFlexibleArguments.new(proc)

    assert_equal proc, call.proc
  end
end
