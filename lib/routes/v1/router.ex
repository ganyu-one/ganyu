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
         ping: :pong
       }}
    )
  end

  get "/single" do
    conn
    |> Util.respond({:ok, Postgres.select_random()})
  end

  get "/all" do
    %Plug.Conn{params: %{"page" => page}} = fetch_query_params(conn)

    case Integer.parse(page) do
      :error ->
        conn
        |> Util.respond({:error, 400, "Page must be an integer"})

      {page, _} ->
        if page < 1 do
          conn
          |> Util.respond({:error, 400, "Page must be greater than 0"})
        else
          conn
          |> Util.respond({:ok, Postgres.select_all(page)})
        end
    end
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
