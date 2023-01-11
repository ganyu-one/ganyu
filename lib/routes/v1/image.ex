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

    case params["page"] |> Util.parse_int() do
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

    indx = params["idx"] |> Util.parse_int()

    idx =
      case indx do
        :error ->
          conn
          |> Util.respond({:error, 400, "Query idx must be an integer"})

        idx when idx < 1 ->
          conn
          |> Util.respond({:error, 400, "Query idx must be greater than 0"})

        idx ->
          idx
      end

    case idx |> Postgres.select_by_idx() do
      nil ->
        conn
        |> Util.not_found("Image not found")

      post ->
        conn
        |> Util.respond({:ok, post})
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
