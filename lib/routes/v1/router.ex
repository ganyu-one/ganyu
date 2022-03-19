defmodule Ganyu.Router.V1 do
  @moduledoc """
  `Ganyu.Router` is a router for Ganyu.
  """

  import Plug.Conn

  alias Ganyu.Router.Util
  alias Ganyu.Router.V1.Data

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/status" do
    conn
    |> Util.respond({:ok, %{total: length(Data.data())}})
  end

  get "/json" do
    conn
    |> Util.respond({:ok, Data.select_random()})
  end

  get "/all" do
    conn
    |> Util.respond({:ok, Data.data()})
  end

  options _ do
    conn
    |> Util.respond({:ok})
  end

  match _ do
    conn
    |> Util.not_found()
  end
end
