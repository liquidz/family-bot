defmodule Brain.Redis do
  use GenServer

  def start_link(uri \\ "redis://localhost:6379") do
    pid = Exredis.start_using_connection_string(uri)
    GenServer.start_link(__MODULE__, pid, name: __MODULE__)
  end

  def handle_call({:get, key, default}, _from, pid) do
    res = case pid |> Exredis.query ["GET", key] do
      :undefined -> default
      val        -> val
    end
    {:reply, res, pid}
  end

  def handle_cast({:set, key, val}, pid) do
    pid |> Exredis.query ["SET", key, val]
    {:noreply, pid}
  end
end
