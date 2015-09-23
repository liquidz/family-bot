defmodule Family do
  use Application

  def start(_type, _args) do
    Family.Supervisor.start_link(nil)
  end
end
