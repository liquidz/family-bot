defmodule Bot.Sample do
  use Slack

  def hear(_text, _message, _slack), do: nil

  def respond(_text, _message, _slack), do: nil
end
