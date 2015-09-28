defmodule Family.Supervisor do
  use Supervisor

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
      Bot.incoming("#{names} がアップデートされたみたいですよ", "general", "天の声", Env.get("Slack_kuma_icon"))
      #Bot.incoming("#{names} がアップデートされたみたいですよ", "dev", "天の声", Env.get("Slack_kuma_icon"))
    end

    res
  end

  def init(_arg) do
    supervise [], strategy: :one_for_one
  end
end
