defmodule Weather.Tomorrow do
  use Timex

  @url     "http://api.openweathermap.org/data/2.5/forecast?q=Musashino,jp"
  @channel "general"

  defp tomorrow do
    Date.local
    |> Date.add(Time.to_timestamp(1, :days))
    |> DateFormat.format!("%Y-%m-%d", :strftime)
  end

  defp ok(x), do: {:ok, x}

  defp post(msg) do
    Bot.incoming(msg, @channel, "何とかジロー", Env.get("Slack_nani_icon"))
  end

  def tomorrow_weather do
    case HTTPoison.get(@url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{"weather" => [%{"main" => main} | _]} = body
        |> Poison.decode!  |> Dict.get("list")
        |> Enum.drop_while(fn %{"dt_txt" => date} ->
          !Regex.match?(~r/^#{tomorrow} 09:00/, date)
        end)
        |> hd
        ok main
      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, "unpexected status: #{status}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "error", reason}
    end
  end

  def notice_weather do
    case tomorrow_weather do
      {:ok, weather} -> cond do
        weather =~ ~r/rain/i ->
          post "明日は雨っぽいですよ"
        weather =~ ~r/snow/i ->
          post "明日は雪かもですよ"
        true -> nil
      end
      _ -> nil
    end
  end
end
