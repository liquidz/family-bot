defmodule Bot do
  use Slack

  @space_regex ~r/( |　)+/

  def handle_message(message = %{type: "message", text: _}, slack, state = [mod]) do
    prefixes = ["<@#{slack.me.id}>: ", "<@#{slack.me.id}> "]

    f = if String.starts_with?(message.text, prefixes) do
      [_user, cmd | _] = String.split(message.text, @space_regex, parts: 3)
      fn -> :"Elixir.Bot.#{mod}".respond(cmd, message, slack) end
    else
      [cmd | _] = String.split(message.text, @space_regex, parts: 2)
      fn -> :"Elixir.Bot.#{mod}".hear(cmd, message, slack) end
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
