defmodule Bot.Panpan.Memo do
  use Slack

  @memo_key "memo"
  
  def process(message, slack) do
    if message.text =~ ~r/(削除|消して)/ do
      data = @memo_key |> Brain.get("{}") |> Poison.decode!
      if Dict.get(data, message.user) == nil do
        send_message("<@#{message.user}> 何もおぼえてないよ？", message.channel, slack)
      else
        json = Dict.delete(data, message.user) |> Poison.encode!
        Brain.set(@memo_key, json)
        send_message("<@#{message.user}> OK", message.channel, slack)
      end
    else
      [_, memo] = message.text |> String.split(~r/ +/, parts: 2)
      json = @memo_key |> Brain.get("{}") |> Poison.decode!
      |> Dict.put(message.user, memo) |> Poison.encode!
      Brain.set(@memo_key, json)
      send_message("<@#{message.user}> おぼえておくね: #{memo}", message.channel, slack)
    end
  end

  def reminder do
    data = @memo_key |> Brain.get("{}") |> Poison.decode!
    data |> Dict.keys |> Enum.each(fn user ->
      Bot.incoming("<@#{user}> おぼえてる？: #{Dict.get(data, user)}",
                   "general", "panpan", Env.get("Slack_panpan_icon"))
    end)
  end
end
