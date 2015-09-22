defmodule Bot.Panpan do
  use Timex
  use Slack

  def hear(text, message, slack) do
    cond do
      # スタンプ
      text =~ ~r/(・・・|\.\.\.)/    -> stamp(:dot, message, slack)
      text =~ ~r/(泣いた|ぶわ|ブワ)/ -> stamp(:buwa, message, slack)
      text =~ ~r/(風呂|おふろ)/      -> stamp(:ohuro, message, slack)
      text =~ ~r/(むっ)/             -> stamp(:mu, message, slack)
      text =~ ~r/(イラ|ｲﾗ)/          -> stamp(:ira, message, slack)
      text =~ ~r/おやすみ/           -> stamp(:oyasumi, message, slack)
      text =~ ~r/(さむい|寒い)/      -> stamp(:samui, message, slack)
      text =~ ~r/(！！|!!)/          -> stamp(:nandatte, message, slack)
      text =~ ~r/(飛べる|跳べる)/    -> stamp(:toberu, message, slack)

      text =~ ~r/(ぱんだ|パンダ)/      -> stamp(:matamata, message, slack)
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
      #m = Regex.run(~r/^set (.+?) (.+?)$/, text) ->
      #  [_, key, val] = m
      #  Brain.set(key, val)
      #  send_message("set: #{key} => #{val}", message.channel, slack)
      #m = Regex.run(~r/^get (.+?)$/, text) ->
      #  [_, key] = m
      #  res = Brain.get(key)
      #  send_message("get: #{key} => #{res}", message.channel, slack)
      true -> nil
    end
  end

  defp stamp(stampId, message, slack) do
    now   = Date.local |> DateFormat.format!("%Y%m%d%H%M%S", :strftime)
    base  = Application.get_env(:Stamp, :base_url)
    image = Application.get_env(:Stamp, stampId) |> Enum.shuffle |> hd

    "#{base}#{image}?_=#{now}"
    |> send_message(message.channel, slack)
  end
end



