defmodule Bot.Panpan.English do
  use Slack

  @question_key "english_question"
  @answered     "answered"
  @channel      "general"

  @words %{
    "assure"              => "確約する、保証する",
    "turn out (to be)"    => "という結果になる",
    "let go of"           => "離す、捨てる",
    "attitude"            => "態度",
    "regardless of"       => "にかかわらず",
    "creed"               => "信条",
    "guarantee"           => "保証する、約束する",
    "lean"                => "傾ける、傾く",
    "lean against on"     => "寄り掛かる",
    "pass by"             => "そばを通り過ぎる",
    "give off"            => "発する",
    "awful"               => "ひどい",
    "stand back"          => "後ろに下がる",
    "scarcely"            => "ほとんど〜ない",
    "tell A from B"       => "AをBと区別する",
    "at times"            => "たまに、時々",
    "those who"           => "という人たち",
    "move over"           => "席を詰める",
    "be apt to"           => "しがちである",
    "as it is"            => "実際のところ",
    "ordinary"            => "普通の、平凡な",
    "compromise"          => "妥協する",
    "to a certain extent" => "ある程度",
    "concrete"            => "具体的な",
    "thorough"            => "徹底的な",
  }


  def question(msg) do
    {word, answer} = random_word
    Brain.set(@question_key, word)

    """
    #{msg}の英単語: `#{word}`
    ```
    #{answer}
    ```
    """
    |> String.strip
    |> Bot.incoming(@channel, "panpan", Env.get("Slack_panpan_icon"))
  end

  defp random_word do
    :random.seed(:os.timestamp)
    @words |> Enum.shuffle |> hd
  end
end
