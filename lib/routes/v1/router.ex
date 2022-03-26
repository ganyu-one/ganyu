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

  match "/ping" do
    conn
    |> Util.respond(
      {:ok,
       %{
         ip: conn.remote_ip |> :inet_parse.ntoa() |> to_string(),
         "user-agent":
           conn.req_headers |> List.keyfind("user-agent", 0) |> Tuple.to_list() |> List.last(),
         method: conn.method
       }}
    )
  end

  get "/single" do
    conn
    |> Util.respond({:ok, Data.select_random()})
  end

  get "/all" do
    conn
    |> Util.respond({:ok, Data.data()})
  end

  get "/status" do
    conn
    |> Util.respond({:ok, %{total: length(Data.data())}})
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
