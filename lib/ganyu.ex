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
      {Ganyu.Database.Postgres, get_db_config()},
      Ganyu.Metrics.Collector
    ]

    opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]

    Logger.info("#{__MODULE__ |> to_string} is running on http://localhost:#{get_port()}")

    Supervisor.start_link(children, opts)
  end

  defp get_port() do
    Application.get_env(:ganyu, :port, 8080)
  end

  defp get_db_config() do
    [
      Application.get_env(
        :ganyu,
        :postgres_hostname
      ),
      Application.get_env(
        :ganyu,
        :postgres_username
      ),
      Application.get_env(
        :ganyu,
        :postgres_password
      ),
      Application.get_env(
        :ganyu,
        :postgres_database
      )
    ]
  end
end
