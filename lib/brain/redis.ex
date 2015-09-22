defmodule Brain.Redis do
  def start_link(uri \\ "redis://localhost:6379") do
    case :global.whereis_name(__MODULE__) do
      :undefined ->
        pid = Exredis.start_using_connection_string(uri)
        :global.register_name(__MODULE__, pid)
        pid
      pid -> pid
    end
  end

  def get(key, default) do
    case __MODULE__ |> :global.whereis_name |> Exredis.query ["GET", key] do
      :undefined -> default
      res        -> res
    end
  end

  def set(key, value) do
    __MODULE__
    |> :global.whereis_name
    |> Exredis.query ["SET", key, value]
  end

  #def keys do
  #  __MODULE__
  #  |> :global.whereis_name
  #  |> Exredis.query ["KEYS", "*"]
  #end
end
