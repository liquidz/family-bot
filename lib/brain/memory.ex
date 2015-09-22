defmodule Brain.Memory do
  def start_link do
    Agent.start_link(fn -> HashDict.new end, name: __MODULE__)
  end

  def get(key, default) do
    Agent.get(__MODULE__, fn m ->
      Dict.get(m, key, default)
    end)
  end

  def set(key, value) do
    Agent.update(__MODULE__, fn m ->
      Dict.put(m, key, value)
    end)
  end
end
