defmodule Ganyu.Database.Postgres do
  @moduledoc """
  `Ganyu.Database.Postgres` is a module that provides connection to Postgres.
  """

  use GenServer

  @page_size 10

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: :ganyu_postgres_client)
  end

  @impl true
  @spec init(any) :: {:ok, %{client: pid}}
  def init(_args) do
    {:ok, client} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "ganyu",
        port: 5432
      )

    Postgrex.prepare(
      client,
      "create_database",
      "CREATE TABLE IF NOT EXISTS images (id SERIAL PRIMARY KEY, url VARCHAR(255) NOT NULL)"
    )

    {:ok, %{client: client}}
  end

  @impl true
  def handle_call({:get_all, page}, _from, state) do
    {:ok, result} =
      Postgrex.query(
        state.client,
        "SELECT id,url FROM images ORDER BY id ASC LIMIT #{@page_size} OFFSET $1",
        [page * @page_size - 10]
      )

    {:reply, result |> result_to_maps, state}
  end

  @impl true
  def handle_call({:get_random}, _from, state) do
    {:ok, result} =
      Postgrex.query(
        state.client,
        "SELECT id,url FROM images ORDER BY RANDOM() LIMIT 1",
        []
      )

    {:reply, result |> result_to_maps, state}
  end

  @impl true
  def handle_call({:exists, url}, _from, state) do
    {:ok, result} =
      Postgrex.query(
        state.client,
        "SELECT id,url FROM images WHERE url = (?)",
        [url]
      )

    {:reply, result |> result_to_maps, state}
  end

  @impl true
  def handle_cast(_event, state) do
    {:noreply, state}
  end

  # public api with pretty formatting

  @proxy_path Application.get_env(:ganyu, :proxy_path, "https://pximg.pxseu.com")

  @spec select_random :: %{idx: String.t(), id: String.t(), url: String.t()}
  def select_random do
    %{"url" => image, "id" => id} =
      GenServer.call(:ganyu_postgres_client, {:get_random}) |> List.first()

    path = "#{@proxy_path}/#{image}"

    pid =
      path
      |> String.split("/")
      |> List.last()
      |> String.split("_")
      |> List.first()

    %{
      idx: id,
      id: pid,
      url: path
    }
  end

  @spec select_all(integer()) :: list(%{idx: String.t(), id: String.t(), url: String.t()})
  def select_all(page) do
    rows = GenServer.call(:ganyu_postgres_client, {:get_all, page})

    rows
    |> Enum.map(fn %{"url" => image, "id" => id} ->
      path = "#{@proxy_path}/#{image}"

      pid =
        path
        |> String.split("/")
        |> List.last()
        |> String.split("_")
        |> List.first()

      %{
        idx: id,
        id: pid,
        url: path
      }
    end)
  end

  @spec data_includes(String.t()) :: boolean
  def data_includes(path) do
    real_path =
      if(path |> String.starts_with?(@proxy_path)) do
        path
        |> String.replace(@proxy_path, "")
      else
        path
      end

    response = GenServer.call(:ganyu_postgres_client, {:exists, real_path})

    response
  end

  defp result_to_maps(%Postgrex.Result{columns: _names, rows: nil}), do: []

  defp result_to_maps(%Postgrex.Result{columns: names, rows: rows}) do
    Enum.map(rows, fn row -> row_to_map(names, row) end)
  end

  defp row_to_map(names, vals) do
    Stream.zip(names, vals)
    |> Enum.into(Map.new())
  end
end
