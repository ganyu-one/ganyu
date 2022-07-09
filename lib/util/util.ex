defmodule Ganyu.Util do
  @moduledoc """
  `Ganyu.Router.Util` is a utility package for Ganyu.
  """

  import Plug.Conn

  require Logger

  @spec respond(Plug.Conn.t(), {:ok, integer, binary}) :: Plug.Conn.t()
  def respond(conn, {:ok, status, body}) do
    conn
    |> put_resp_header("server", "ganyu")
    |> send_resp(status, body)
  end

  @spec respond(Plug.Conn.t(), {:ok}) :: Plug.Conn.t()
  def respond(conn, {:ok}) do
    conn |> respond({:ok, 204, ""})
  end

  @spec respond(Plug.Conn.t(), {:ok, Poison.Encoder.t()}) :: Plug.Conn.t()
  def respond(conn, {:ok, data}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> respond({:ok, 200, Poison.encode!(%{success: true, data: data})})
  end

  @spec respond(Plug.Conn.t(), {:error, integer}) :: Plug.Conn.t()
  def respond(conn, {:error, status}) do
    conn |> respond({:error, status, nil})
  end

  @spec respond(Plug.Conn.t(), {:error, integer, any}) :: Plug.Conn.t()
  def respond(conn, {:error, status, message}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> respond(
      {:ok, status,
       Poison.encode!(%{
         success: false,
         data: nil,
         message: message
       })}
    )
  end

  def parse_int(str, base \\ 10)
  def parse_int(nil, _), do: :error

  def parse_int(str, base) do
    case Integer.parse(str, base) do
      {int, ""} -> int
      _ -> :error
    end
  end

  def lower_headers(headers: nil), do: nil
  def lower_headers(headers: []), do: []

  def lower_headers(headers) do
    headers
    |> Enum.map(fn {k, v} ->
      {k |> String.downcase(), v}
    end)
  end

  def ok(conn) do
    conn |> respond({:ok})
  end

  def not_found(conn, message \\ "Not Found") do
    conn
    |> respond({:error, 404, message})
  end

  def internal_error(conn) do
    conn
    |> respond({:error, 500, "Internal Server Error"})
  end
end
