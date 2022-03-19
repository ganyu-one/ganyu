defmodule Ganyu.Router do
  @moduledoc """
  `Ganyu.Router` is a router for Ganyu.
  """

  import Plug.Conn

  alias Ganyu.Router.V1
  alias Ganyu.Router.Util
  alias Ganyu.Router.V1.Data

  use Plug.Router

  plug(Corsica,
    origins: "*",
    max_age: 600,
    allow_methods: :all,
    allow_headers: :all
  )

  plug(:match)
  plug(:dispatch)

  forward("/v1", to: V1)

  # see https://github.com/edgurgel/httpoison
  # see https://ninenines.eu/docs/en/cowboy/2.4/manual/cowboy_stream/

  get "/" do
    %HTTPoison.Response{body: b, headers: h, status_code: s} =
      HTTPoison.get!(
        Data.select_random().url,
        [{"referer", "https://www.pixiv.net/"}]
      )

    case s do
      200 ->
        {_, content_type} =
          h
          |> List.keyfind("Content-Type", 0)

        conn
        |> put_resp_content_type(content_type)
        |> send_resp(200, b)

      c ->
        conn
        |> send_resp(c, "")
    end
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
