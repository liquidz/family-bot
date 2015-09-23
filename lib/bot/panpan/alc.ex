defmodule Bot.Panpan.Alc do
  use Slack

  @url "http://eow.alc.co.jp/search"

  # alc での検索結果をPOSTする
  def process(message, slack) do
    [_, q] = message.text |> String.split(~r/ +/, parts: 2)
    case query(q) do
      ""  -> send_message("<@#{message.user}> わからなかった。。", message.channel, slack)
      res ->
        send_message("""
        <@#{message.user}> しらべたよ
        ```
        #{res}
        ```
        """, message.channel, slack)
    end
  end

  def query(q) do
    {:ok, res} = HTTPoison.get(@url <> "?q=" <> q)
    div = res.body |> Floki.find("#resultsList ul li div")

    if Enum.empty?(div) do
      ""
    else
      div
      |> hd
      |> child
      |> Enum.flat_map(fn x ->
        case x do
          {"span", [{"class", "wordclass"}], _} -> [Floki.text(x)]
          {"ol", _, ls}                         -> Enum.map(ls, &Floki.text/1)
          {"ul", [{"class", "ul_je"}], ls}      -> Enum.map(ls, &Floki.text/1)
          _                                     -> []
        end
      end)
      |> Enum.join("\n")
    end
  end

  defp child({_, _, child_html}), do: child_html
end
