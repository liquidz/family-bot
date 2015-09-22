defmodule Bot do
  use Slack

  def handle_message(message = %{type: "message", text: _}, slack, state = [mod]) do
    trigger = String.split(message.text, ~r{( |　)+}, parts: 2)
    case String.starts_with?(message.text, "<@#{slack.me.id}>: ") do
      true  -> :"Elixir.Bot.#{mod}".respond(Enum.at(trigger, 1), message, slack)
      false -> :"Elixir.Bot.#{mod}".hear(hd(trigger), message, slack)
    end
    {:ok, state}
  end

  def handle_message(_, _, state), do: {:ok, state}

  def incoming(text, channel, user, icon) do
    url = Env.get("Slack_incoming_url")
    json = %{
      text:     text,
      channel:  "##{channel}",
      username: user,
      icon_url: icon
    } |> Poison.encode!

    HTTPoison.post(url, json)
    |> IO.inspect

  end
end
