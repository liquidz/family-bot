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

  def respond("単語", m, s), do: Bot.Panpan.English.check_answer(m, s)
  def respond("降参", m, s), do: Bot.Panpan.English.give_up(m, s)

  def respond("おそい", message, slack) do
    ~w{ お く れ て 聞 こ え る よ }
    |> Enum.each(fn c ->
      send_message(c, message.channel, slack)
      :timer.sleep(1000)
    end)
  end
  def respond("help", message, slack) do
    help = Application.get_env(:Family, :help) |> String.strip
    send_message("""
    ```
    #{help}
    ```
    """, message.channel, slack)
  end

  def respond("debug", message, slack) do
    case message.text |> String.strip |> String.split(~r/ +/, parts: 3) do
      [_, _, "vim test"]   -> Vim.Version.check_now
      [_, _, "vim latest"] -> Vim.Version.check_latest
      [_, _, "english"]    -> Bot.Panpan.English.question
      _                    -> nil
    end
  end

  def respond("set", message, slack) do
    [_user, _set, k, v] = String.split(message.text, ~r/ +/, parts: 4)
    Brain.set(k, v)
    send_message("set: #{k} => #{v}", message.channel, slack)
  end

  def respond("get", message, slack) do
    [_user, _get, k] = String.split(message.text, ~r/ +/, parts: 3)
    res = Brain.get(k, "nil")
    send_message("get: #{k} => #{res}", message.channel, slack)
  end

  def respond(unknown, message, _) do
    IO.puts("command: [#{unknown}], message: [#{message.text}]")
  end

  def reminder(msg) do
    Bot.incoming(msg, "general", "panpan", Env.get("Slack_panpan_icon"))
  end

  defp stamp(stampId, message, slack) do
    :random.seed(:os.timestamp)
    now   = Date.local |> DateFormat.format!("%Y%m%d%H%M%S", :strftime)
    base  = Application.get_env(:Stamp, :base_url)
    image = Application.get_env(:Stamp, stampId) |> Enum.shuffle |> hd

    "#{base}#{image}?#{now}"
    |> send_message(message.channel, slack)
  end
end
