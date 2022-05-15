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
  use Plug.ErrorHandler

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
    %{url: url, idx: idx} = Postgres.select_random()

    %HTTPoison.Response{body: b, headers: h, status_code: s} =
      HTTPoison.get!(
        url,
        [{"referer", "https://www.pixiv.net/"}]
      )

    case s do
      200 ->
        {_, content_type} =
          h
          |> Util.lower_headers()
          |> List.keyfind("content-type", 0)

        conn
        |> put_resp_header("content-type", content_type)
        |> put_resp_header("x-image-idx", idx |> to_string)
        |> Util.respond({:ok, s, b})

      _ ->
        conn
        |> Util.internal_error()
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

  defp handle_errors(conn, _) do
    conn
    |> Util.internal_error()
  end
end
