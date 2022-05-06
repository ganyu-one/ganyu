defmodule Ganyu.Util do
  @moduledoc """
  `Ganyu.Router.Util` is a utility package for Ganyu.
  """

  import Plug.Conn

  @spec respond(Plug.Conn.t(), {:ok, integer, binary}) :: Plug.Conn.t()
  def respond(conn, {:ok, status, body}) do
    conn
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

  def ok(conn) do
    conn |> respond({:ok})
  end

  @spec not_found(Plug.Conn.t()) :: Plug.Conn.t()
  def not_found(conn) do
    conn
    |> respond({:error, 404, "Not Found"})
  end
end
