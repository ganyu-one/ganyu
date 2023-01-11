defmodule Ganyu.Router.V1 do
  @moduledoc """
  `Ganyu.Router` is a router for Ganyu.
  """

  alias Ganyu.Util
  alias Ganyu.Metrics.Collector
  alias Ganyu.Router.V1.Image

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  forward("/image", to: Image)

  get "/metrics" do
    conn
    |> Util.respond({:ok, Collector.get_state()})
  end

  options _ do
    conn
    |> Util.ok()
  end

  match _ do
    conn
    |> Util.not_found()
  end
end
