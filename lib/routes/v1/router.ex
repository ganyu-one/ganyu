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

  get "/single" do
    conn
    |> Util.respond({:ok, Postgres.select_random(nil)})
  end

  get "/all" do
    %Plug.Conn{params: params} = fetch_query_params(conn)

    page =
      case params do
        %{"page" => page} -> Integer.parse(page)
        _ -> {1, nil}
      end

    case page do
      :error ->
        conn
        |> Util.respond({:error, 400, "Page must be an integer"})

      {page, _} ->
        if page < 1 do
          conn
          |> Util.respond({:error, 400, "Page must be greater than 0"})
        else
          conn
          |> Util.respond({:ok, Postgres.select_all(nil, page)})
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
