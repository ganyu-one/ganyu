defmodule Ganyu do
  readme_path = [__DIR__, "..", "README.md"] |> Path.join() |> Path.expand()

  @external_resource readme_path
  @moduledoc readme_path |> File.read!() |> String.trim()

  use Application

  require Logger

  def start(_type, _args) do
    Logger.info("Starting #{__MODULE__ |> to_string}...")

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Ganyu.Router,
        options: [port: get_port()]
      ),
      Ganyu.Metrics.Collector.child_spec([]),
      Ganyu.Database.Postgres.child_spec([])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]

    {:ok, pid} = Supervisor.start_link(children, opts)

    Logger.info("#{__MODULE__ |> to_string} is running on http://localhost:#{get_port()}")

    {:ok, pid}
  end

  defp get_port() do
    Application.get_env(:ganyu, :port, 8080)
  end
end
