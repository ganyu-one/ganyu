defmodule Ganyu do
  @moduledoc """
  `Ganyu` is an application for delievering random images from Pixiv of Ganyu.
  """

  use Application

  def start(_type, _args) do
    :ets.new(:bruh, [:named_table, :set, :public])

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Ganyu.Router,
        options: [port: Application.get_env(:ganyu, :port, 8080)]
      )
    ]

    opts = [strategy: :one_for_one, name: Ganyu.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
