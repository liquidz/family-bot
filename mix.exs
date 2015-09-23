defmodule Family.Mixfile do

  use Mix.Project

  def project do
    [
      app:     :family,
      version: "0.0.1",
      elixir:  "~> 1.0",
      aliases: aliases,
      deps:    deps
    ]
  end

  def application do
    [
      applications: [:logger, :tzdata, :slack, :quantum, :httpoison],
      mod:          {Family, []}
    ]
  end

  def aliases do
    [
      start: "run --no-halt"
    ]
  end

  defp deps do
    [
      {:mock,      "~> 0.1.1"},
      {:quantum,   ">= 1.4.0"},
      {:timex,     "~> 0.19.4"},
      {:httpoison, "~> 0.7.2"},
      {:exredis,   ">= 0.2.0"},
      {:poison,    "~> 1.5"},
      {:slack,     "~> 0.2.0"},
      {:websocket_client, git: "https://github.com/jeremyong/websocket_client"},
    ]
  end
end
