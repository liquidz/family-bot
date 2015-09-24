defmodule Bot do
  use Slack

  def handle_message(message = %{type: "message", text: _}, slack, state = [mod]) do
    trigger = String.split(message.text, ~r{( |　)+}, parts: 2)
    f = if String.starts_with?(message.text, "<@#{slack.me.id}>: ") do
      fn -> :"Elixir.Bot.#{mod}".respond(Enum.at(trigger, 1), message, slack) end
    else
      fn -> :"Elixir.Bot.#{mod}".hear(hd(trigger), message, slack) end
    end
    Task.start(f)
    {:ok, state}
  end

  def handle_message(_, _, state), do: {:ok, state}

  def handle_close(reason, slack, state) do
    Bot.incoming("""
    エラーが発生したぞ
    ```
    REASON: #{inspect reason}
    STATE : #{inspect state}
    ```
    """ , "dev", "リーダー", Env.get("Slack_paiman_icon"))

    {:error, state}
  end

  def incoming(text, channel, user, icon) do
    url = Env.get("Slack_incoming_url")
    json = %{
      text:     text,
      channel:  "##{channel}",
      username: user,
      icon_url: icon
    } |> Poison.encode!

    HTTPoison.post(url, json)
  end
end
