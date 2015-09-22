defmodule EnvTest do
  use ExUnit.Case

  test "get" do
    assert Env.get("Family_test") == "test config"
  end
end
