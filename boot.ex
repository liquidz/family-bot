# Brain の起動
# 開発時には memory を利用する
production? = System.argv |> hd == "prod"

if production? do
  IO.puts "PRODUCTION"
  Brain.Redis.start_link(Env.get("Redis_url"))
  Brain.init(Brain.Redis)
else
  IO.puts "DEVELOPMENT"
  Brain.Memory.start_link
  Brain.init(Brain.Memory)
end

~w{ Panpan }
|> Enum.each(fn mod ->
  IO.puts "#{mod}: starting"
  token = Env.get("#{mod}_api_token")
  Bot.start_link(token, [mod])
  IO.puts "#{mod}: ok"

  if production? do
    Bot.incoming("#{mod} が起きたみたいですよ", "general", "天の声", Env.get("Slack_kuma_icon"))
  end
end)
