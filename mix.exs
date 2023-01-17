defmodule Ganyu.MixProject do
  use Mix.Project

  def project do
    [
      app: :ganyu,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :plug_cowboy, :postgrex],
      mod: {Ganyu, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 5.0"},
      {:corsica, "~> 1.0"},
      {:httpoison, "~> 1.8"},
      {:postgrex, "~> 0.16.2"},
      {:libcluster, "~> 3.3"},
      {:libcluster_hop,
       github: "hiett/libcluster_hop", ref: "6e3a00d2e8e8ea0388135d8c000b999536021909"}
    ]
  end
end
