defmodule Bot.PanpanTest do
  use ExUnit.Case
  import Mock

  test_with_mock "ping pong test",
  Slack, [:passthrough], [send_message: fn (s, _, _) -> s end] do
    res = Bot.Panpan.respond("ping", %{channel: "dummy"}, nil)
    assert res == "pong"
  end
end
