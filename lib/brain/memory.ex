defmodule Brain.Memory do
  use GenServer

  def start_link(_ \\ nil) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def handle_call({:get, key, default}, _from, state) do
    {:reply, Dict.get(state, key, default), state}
  end

  def handle_cast({:set, key, val}, state) do
    {:noreply, Dict.put(state, key, val)}
  end
end
