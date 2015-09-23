defmodule Brain do
  use GenServer

  def start_link(mod, arg \\ nil) do
    {:ok, brain} = mod.start_link(arg)
    GenServer.start_link(__MODULE__, brain, name: __MODULE__)
  end

  def handle_call(action, _from, brain) do
    {:reply, GenServer.call(brain, action), brain}
  end

  def handle_cast(action, brain) do
    GenServer.cast(brain, action)
    {:noreply, brain}
  end

  def get(key, default) do
    GenServer.call(__MODULE__, {:get, key, default})
  end

  def set(key, val) do
    GenServer.cast(__MODULE__, {:set, key, val})
  end
end
