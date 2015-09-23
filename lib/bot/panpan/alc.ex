defmodule Bot.Panpan.Alc do
  use Slack

  @url "http://eow.alc.co.jp/search"

  def process(message, slack) do
    [_, q] = message.text |> String.split(~r/ +/, parts: 2)
    res = query(q)

    send_message("""
    <@#{message.user}> しらべたよ
    ```
    #{res}
    ```
    """, message.channel, slack)
  end

  def query(q) do
    {:ok, res} = HTTPoison.get(@url <> "?q=" <> q)

    res.body
    |> Floki.find("#resultsList ul li div")
    |> hd
    |> child
    |> Enum.flat_map(fn x ->
      case x do
        {"span", [{"class", "wordclass"}], _} -> [Floki.text(x)]
        {"ol", _, ls}                         -> Enum.map(ls, &Floki.text/1)
        _                                     -> []
      end
    end)
    |> Enum.join("\n")
  end

  defp child({_, _, child_html}), do: child_html
end
