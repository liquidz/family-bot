defmodule Family.SubSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    children = Application.get_env(:Slack, :bots)
    |> Enum.map(fn mod ->
      case Env.get("#{mod}_api_token") do
        nil   -> nil
        token -> worker(Bot, [token, [mod]])
      end
    end)
    |> Enum.reject(&(&1 == nil))

    supervise children, strategy: :one_for_one
  end
end
