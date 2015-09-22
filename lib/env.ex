defmodule Env do
  def get(key) do
    case key |> System.get_env do
      nil ->
        [app, app_key] = String.split(key, ~r/_/, parts: 2)
        Application.get_env(:"#{app}", :"#{app_key}")
      s   -> s
    end
  end
end
