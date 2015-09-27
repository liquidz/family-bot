defmodule Bot.Panpan.English do
  use Slack

  @question_key "english_question"
  @answered     "answered"
  @channel      "general"

  @words %{
    "assure"              => ~r/(確約|保証)する/,
    "turn out (to be)"    => ~r/(という)?結果になる/,
    "let go of"           => ~r/(離す|捨てる)/,
    "attitude"            => ~r/態度/,
    "regardless of"       => ~r/にかかわらず/,
    "creed"               => ~r/信条/,
    "guarantee"           => ~r/(保証|約束)する/,
    "lean"                => ~r/傾(ける|く)/,
    "lean against on"     => ~r/(寄り掛かる|寄りかかる)/,
    "pass by"             => ~r/そばを通り過ぎる/,
    "give off"            => ~r/発する/,
    "awful"               => ~r/ひどい/,
    "stand back"          => ~r/後ろに下がる/,
    "scarcely"            => ~r/ほとんど(〜|-| )ない/,
    "tell A from B"       => ~r/AをBと区別する/,
    "at times"            => ~r/(たまに|時々|ときどき)/,
    "those who"           => ~r/という人たち/,
    "move over"           => ~r/席を詰める/,
    "be apt to"           => ~r/しがち(である)?/,
    "as it is"            => ~r/実際のところ/,
    "ordinary"            => ~r/(普通の|平凡な)/,
    "compromise"          => ~r/妥協する/,
    "to a certain extent" => ~r/ある程度/,
    "concrete"            => ~r/具体的な/,
    "thorough"            => ~r/徹底的な/,
    "thorough"            => ~r/徹底的な/,
  }


  def question do
    word = random_word
    Brain.set(@question_key, word)

    "今日の英単語: `#{word}`"
    |> Bot.incoming(@channel, "panpan", Env.get("Slack_panpan_icon"))
  end

  def question_reminder do
    case Brain.get(@question_key, "") do
      @answered -> nil
      word      ->
        """
        まだ回答してないよ？
        今日の英単語: `#{word}`
        """
        |> String.strip
        |> Bot.incoming(@channel, "panpan", Env.get("Slack_panpan_icon"))
    end
  end

  def check_answer(message, slack) do
    case Brain.get(@question_key, "") do
      ""        -> "問題が取得できなかった :sweat:"
      @answered -> "もう回答済みだよ :grin:"
      word      ->
        if message.text =~ Dict.get(@words, word) do
          Brain.set(@question_key, @answered)
          "<@#{message.user}> 正解 :tada:"
        else
          "<@#{message.user}> ぶぶー :stuck_out_tongue_closed_eyes:"
        end
    end
    |> send_message(message.channel, slack)
  end

  def give_up(message, slack) do
    case get_answer_text do
      {"", ""}        -> "問題が取得できなかった :sweat:"
      {@answered, ""} -> "もう回答済みだよ :grin:"
      {_word, answer} ->
        Brain.set(@question_key, @answered)
        "<@#{message.user}>: 正解は `#{answer}` だよ :stuck_out_tongue_winking_eye:"
    end
    |> send_message(message.channel, slack)
  end

  def time_up do
    case get_answer_text do
      {"", ""}        -> nil
      {@answered, ""} -> nil
      {word, answer}  ->
        Brain.set(@question_key, @answered)
        "今日の英単語: `#{word}` の意味は `#{answer}` でした :stuck_out_tongue_winking_eye:"
        |> Bot.incoming(@channel, "panpan", Env.get("Slack_panpan_icon"))
    end
  end

  defp random_word do
    :random.seed(:os.timestamp)
    {word, _} = @words |> Enum.shuffle |> hd
    word
  end

  defp get_answer_text do
    case Brain.get(@question_key, "") do
      ""         -> {"", ""}
      @answered  -> {@answered, ""}
      word       ->
        answer = "#{inspect Dict.get(@words, word)}"
        |> String.replace("~r", "")
        |> String.replace("/", "")
        {word, answer}
    end
  end
end
