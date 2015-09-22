defmodule BrainTest do
  use ExUnit.Case

  test "memory" do
    Brain.Memory.start_link
    Brain.init(Brain.Memory)

    assert Brain.get("foo", "default") == "default"
    Brain.set("foo", "bar")
    assert Brain.get("foo", "default") == "bar"
    Brain.set("foo", "baz")
    assert Brain.get("foo", "default") == "baz"
  end
end
