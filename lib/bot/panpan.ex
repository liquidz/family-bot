defmodule Bot.Panpan do
  use Timex
  use Slack

  def hear("raise_error", message, slack) do
    Brain.get("hoge")
    send_message("test", message.channel, slack)
  end

  def hear("メモ", message, slack), do: Bot.Panpan.Memo.process(message, slack)
  def hear("alc", message, slack), do: Bot.Panpan.Alc.process(message, slack)

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
      #message.text =~ ~r/おやすみ/           -> stamp(:oyasumi, message, slack)
      message.text =~ ~r/(さむい|寒い)/      -> stamp(:samui, message, slack)

      message.text =~ ~r/(ぱんだ|パンダ)/ ->
        send_message("<@#{message.user}> よんだ？", message.channel, slack)
      message.text =~ ~r/パンパン/ ->
        cond do
          message.text =~ ~r/おやすみ/ ->
            t = case message.user do
              "U02C1CPES" -> "おやしゅみパパ :sleepy:"
              "U0B40R9B6" -> "おやしゅみママ :kissing_closed_eyes: めぐむたん :kissing_closed_eyes:"
              _           -> "おやしゅみ"
            end
            send_message("<@#{message.user}> #{t}", message.channel, slack)
          true -> nil
        end
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
  def respond("help", message, slack) do
    help = Application.get_env(:Family, :help) |> String.strip
    send_message("""
    ```
    #{help}
    ```
    """, message.channel, slack)
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

  def reminder(msg) do
    Bot.incoming(msg, "general", "panpan", Env.get("Slack_panpan_icon"))
  end

  defp stamp(stampId, message, slack) do
    now   = Date.local |> DateFormat.format!("%Y%m%d%H%M%S", :strftime)
    base  = Application.get_env(:Stamp, :base_url)
    image = Application.get_env(:Stamp, stampId) |> Enum.shuffle |> hd

    "#{base}#{image}?#{now}"
    |> send_message(message.channel, slack)
  end
end
