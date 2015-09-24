defmodule Trash.Week do
  use Timex

  def bin_kan do
    """
    今日はびん・缶・古紙・古着ごみの日ですよ
    *注意*
    古紙などを袋に入れる場合は「ざつがみ」
    乾電池やスプレー缶などは透明袋に「有害ごみ」と書くのを忘れないように
    """
    |> String.strip
    |> post
  end

  def moyasu do
    post "今日は燃やすごみの日ですよ"
  end

  def pura do
    post "今日はプラスチックごみの日ですよ"
  end

  def moyasanai do
    d = Date.local.day
    flag = cond do
      ((d - 7) > 0 && (d - 7 * 2) < 0)     -> true # 第2
      ((d - 7 * 3) > 0 && (d - 7 * 4) < 0) -> true # 第4
      true                                 -> false
    end

    if flag do
      """
      今日は燃やさないごみの日です。
      *注意*
      燃やさないゴミはガラス、鍋、金属製の食器、陶器、電球などです
      ただし蛍光灯は有害ごみなので注意しましょう
      """
      |> String.strip
      |> post
    end
  end

  defp post(msg) do
    Bot.incoming(msg, "general", "五味さん", Env.get("Slack_gomi_icon"))
  end
end
