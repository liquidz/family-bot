case System.argv |> hd do
  "prod" ->
    IO.puts "PRODUCTION"
    Brain.Redis.start_link(Env.get("Redis_url"))
    Brain.init(Brain.Redis)
  _ ->
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
end)
