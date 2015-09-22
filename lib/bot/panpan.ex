defmodule Bot.Panpan do
  use Timex
  use Slack

  @memo_key "memo"

  def hear("メモ", message, slack) do
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

  def hear(text, message, slack) do
    cond do
      # スタンプ
      text =~ ~r/(・・・|\.\.\.)/    -> stamp(:dot, message, slack)
      text =~ ~r/(むっ)/             -> stamp(:mu, message, slack)
      message.text =~ ~r/(泣いた|ぶわ|ブワ)/ -> stamp(:buwa, message, slack)
      message.text =~ ~r/(風呂|おふろ)/      -> stamp(:ohuro, message, slack)
      message.text =~ ~r/(飛べる|跳べる)/    -> stamp(:toberu, message, slack)
      message.text =~ ~r/(！！|!!)/          -> stamp(:nandatte, message, slack)
      message.text =~ ~r/(イラ|ｲﾗ)/          -> stamp(:ira, message, slack)
      message.text =~ ~r/おやすみ/           -> stamp(:oyasumi, message, slack)
      message.text =~ ~r/(さむい|寒い)/      -> stamp(:samui, message, slack)

      message.text =~ ~r/(ぱんだ|パンダ)/ ->
        send_message("<@#{message.user}> よんだ？", message.channel, slack)
      true ->
        nil
    end
  end

  def respond("ping", message, slack) do
    send_message("pong", message.channel, slack)
  end
  def respond("date", message, slack) do
    Date.local
    |> DateFormat.format!("%Y/%m/%d %H:%M:%S", :strftime)
    |> send_message(message.channel, slack)
  end

  def respond(text, message, slack) do
    cond do
      m = Regex.run(~r/^set (.+?) (.+?)$/, text) ->
        [_, key, val] = m
        Brain.set(key, val)
        send_message("set: #{key} => #{val}", message.channel, slack)
      m = Regex.run(~r/^get (.+?)$/, text) ->
        [_, key] = m
        res = Brain.get(key, "nil")
        send_message("get: #{key} => #{res}", message.channel, slack)
      true -> nil
    end
  end

  def memo_reminder do
    data = @memo_key |> Brain.get("{}") |> Poison.decode!
    data |> Dict.keys |> Enum.each(fn user ->
      Bot.incoming("<@#{user}> おぼえてる？: #{Dict.get(data, user)}",
                   "general", "panpan", Env.get("Slack_panpan_icon"))
    end)
  end

  defp stamp(stampId, message, slack) do
    now   = Date.local |> DateFormat.format!("%Y%m%d%H%M%S", :strftime)
    base  = Application.get_env(:Stamp, :base_url)
    image = Application.get_env(:Stamp, stampId) |> Enum.shuffle |> hd

    "#{base}#{image}?_=#{now}"
    |> send_message(message.channel, slack)
  end
end
