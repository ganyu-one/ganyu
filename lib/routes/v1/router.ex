defmodule Ganyu.Router.V1 do
  @moduledoc """
  `Ganyu.Router` is a router for Ganyu.
  """

  import Plug.Conn

  alias Ganyu.Util
  alias Ganyu.Database.Postgres

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  match "/ping" do
    conn
    |> Util.respond(
      {:ok,
       %{
         "user-agent":
           conn.req_headers |> List.keyfind("user-agent", 0) |> Tuple.to_list() |> List.last(),
         method: conn.method
       }}
    )
  end

  get "/single" do
    conn
    |> Util.respond({:ok, Postgres.select_random()})
  end

  get "/all" do
    conn
    |> Util.respond({:ok, Postgres.select_all()})
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
