defmodule Ganyu.Router.V1.Image do
  @moduledoc """
  `Ganyu.Router.V1.Image` is a router for images for Ganyu.
  """

  import Plug.Conn

  alias Ganyu.Util
  alias Ganyu.Database.Postgres

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/single" do
    conn
    |> Util.respond({:ok, Postgres.select_random()})
  end

  get "/all" do
    %Plug.Conn{params: params} = fetch_query_params(conn)

    case Util.parse_int(params["page"]) do
      :error ->
        conn
        |> Util.respond({:error, 400, "Query page must be an integer"})

      page when page < 1 ->
        conn
        |> Util.respond({:error, 400, "Query page must be greater than 0"})

      page ->
        conn
        |> Util.respond({:ok, Postgres.select_all(page)})
    end
  end

  get "/:idx" do
    %Plug.Conn{path_params: params} = conn

    indx = Util.parse_int(params["idx"])

    case indx do
      :error ->
        conn
        |> Util.respond({:error, 400, "Query idx must be an integer"})

      idx when idx < 1 ->
        conn
        |> Util.respond({:error, 400, "Query idx must be greater than 0"})

      idx ->
        case Postgres.select_by_idx(idx) do
          nil ->
            conn
            |> Util.not_found()

          post ->
            conn
            |> Util.respond({:ok, post})
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
