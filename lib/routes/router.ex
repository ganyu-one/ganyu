defmodule Ganyu.Router do
  @moduledoc """
  `Ganyu.Router` is a router for Ganyu.
  """

  import Plug.Conn

  alias Ganyu.Util
  alias Ganyu.Router.V1
  alias Ganyu.Database.Postgres

  use Plug.Router

  plug(Plug.Logger, log: :info)

  plug(Corsica,
    origins: "*",
    max_age: 600,
    allow_methods: :all,
    allow_headers: :all
  )

  plug(:match)
  plug(:dispatch)

  forward("/v1", to: V1)

  get "/" do
    %HTTPoison.Response{body: b, headers: h, status_code: s} =
      HTTPoison.get!(
        Postgres.select_random().url,
        [{"referer", "https://www.pixiv.net/"}]
      )

    case s do
      200 ->
        {_, content_type} =
          h
          |> List.keyfind("Content-Type", 0)

        conn
        |> put_resp_content_type(content_type)
        |> Util.respond({:ok, 200, b})

      c ->
        conn
        |> Util.respond({:ok, c, ""})
    end
  end

  get "/favicon.ico" do
    conn
    |> Util.respond({:ok, 204, ""})
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
