defmodule Family.Supervisor do
  use Supervisor

  @channel "general"

  def start_link(_arg) do
    {:ok, sup} = Supervisor.start_link(__MODULE__, nil)

    {brain_worker, production?} = case Env.get("Redis_url") do
      nil -> {worker(Brain, [Brain.Memory, nil]), false}
      url -> {worker(Brain, [Brain.Redis,  url]), true}
    end

    if production? do
      IO.puts "# PRODUCTION"
    else
      IO.puts "# DEVELOPMENT"
    end

    IO.puts "# Brain worker: starting"
    Supervisor.start_child(sup, brain_worker)
    IO.puts "# Brain worker: ok"

    IO.puts "# Bots supervisor: starting"
    res = Supervisor.start_child(sup, supervisor(Family.SubSupervisor, [production?]))
    IO.puts "# Bots supervisor: ok"

    if production? do
      names = Application.get_env(:Slack, :bots) |> Enum.join(", ")
      case 1..10 |> Enum.shuffle |> hd |> rem(2) do
        0 ->
          "#{names} がアップデートされたみたいですよ"
          |> Bot.incoming(@channel, "天の声", Env.get("Slack_kuma_icon"))
        _ ->
          "ぱわーあっぷ :muscle:"
          |> Bot.incoming(@channel, "panpan", Env.get("Slack_panpan_icon"))
      end
    end

    res
  end

  def init(_arg) do
    supervise [], strategy: :one_for_one
  end
end
