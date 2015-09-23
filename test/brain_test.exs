defmodule BrainTest do
  use ExUnit.Case, async: true

  test "get and set" do
    assert Brain.get("foo", "default") == "default"
    Brain.set("foo", "bar")
    assert Brain.get("foo", "default") == "bar"
    Brain.set("foo", "baz")
    assert Brain.get("foo", "default") == "baz"
  end
end
