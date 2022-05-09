defmodule Ganyu.Router do
  @moduledoc """
  `Ganyu.Router` is a router for Ganyu.
  """

  import Plug.Conn

  alias Ganyu.Util
  alias Ganyu.Router.V1
  alias Ganyu.Metrics.Collector
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
  plug(:metrics)

  def metrics(conn, _) do
    Collector.inc_requests(conn.status)

    conn
  end

  forward("/v1", to: V1)

  get "/" do
    try do
      %HTTPoison.Response{body: b, headers: h, status_code: s} =
        HTTPoison.get!(
          Postgres.select_random("https://i.pximg.net/").url,
          [{"referer", "https://www.pixiv.net/"}]
        )

      case s do
        200 ->
          conn
          |> merge_resp_headers(
            h
            |> Enum.map(fn {k, v} -> {k |> String.downcase(), v} end)
          )
          |> Util.respond({:ok, 200, b})

        c ->
          conn
          |> Util.respond({:ok, c, ""})
      end
    rescue
      _ ->
        conn
        |> Util.respond({:error, 500, "Internal Server Error"})
    end
  end

  get "/favicon.ico" do
    conn
    |> put_resp_header("cache-control", "public, max-age=86400")
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
