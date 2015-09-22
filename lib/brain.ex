defmodule Brain do
  def init(mod) do
    case Agent.start(fn -> mod end, name: __MODULE__) do
      {:error, {:already_started, pid}} ->
        Agent.update(pid, fn _ -> mod end)
      res -> res
    end
  end

  def get(key, default) do
    Agent.get(__MODULE__, fn mod ->
      mod.get(key, default)
    end)
  end

  def set(key, value) do
    Agent.get(__MODULE__, fn mod ->
      mod.set(key, value)
    end)
  end

  #def keys do
  #  Agent.get(__MODULE__, fn mod ->
  #    mod.keys
  #  end)
  #end
end
