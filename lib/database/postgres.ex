defmodule Ganyu.Database.Postgres do
  @moduledoc """
  `Ganyu.Database.Postgres` is a module that provides connection to Postgres.
  """

  use GenServer

  alias Ganyu.Metrics.Collector

  require Logger

  @client :ganyu_postgres_client
  @page_size 10

  def start_link(data) do
    GenServer.start_link(__MODULE__, data, name: @client)
  end

  @impl true
  def init([hostname, username, password, database, proxy_path]) do
    {:ok, client} =
      Postgrex.start_link(
        hostname: hostname,
        username: username,
        password: password,
        database: database,
        port: 5432
      )

    client |> init_call()

    {:ok, %{client: client, proxy: proxy_path}}
  end

  defp init_call(client) do
    query = "CREATE TABLE IF NOT EXISTS images (id SERIAL PRIMARY KEY, url VARCHAR(255) NOT NULL)"

    {:ok, _} = Postgrex.query(client, query, [])
  end

  @impl true
  def handle_call({:get_all, page}, _from, state) do
    query = "SELECT id,url FROM images ORDER BY id ASC LIMIT #{@page_size} OFFSET $1"

    {:ok, result} = Postgrex.query(state[:client], query, [page * @page_size - 10])

    {:reply,
     %{
       rows: result |> result_to_maps,
       proxy: state[:proxy]
     }, state}
  end

  @impl true
  def handle_call({:get_random}, _from, state) do
    query = "SELECT id,url FROM images ORDER BY RANDOM() LIMIT 1"

    {:ok, result} = Postgrex.query(state[:client], query, [])

    {:reply,
     %{
       rows: result |> result_to_maps |> List.first(),
       proxy: state[:proxy]
     }, state}
  end

  @impl true
  def handle_call({:get_by_id, id}, _from, state) do
    query = "SELECT id,url FROM images WHERE id = ($1)"

    {:ok, result} = Postgrex.query(state[:client], query, [id])

    {:reply,
     %{
       rows: result |> result_to_maps |> List.first(),
       proxy: state[:proxy]
     }, state}
  end

  @impl true
  def handle_cast(_event, state) do
    {:noreply, state}
  end

  # public api with pretty formatting
  @spec select_random :: %{id: String.t(), idx: integer(), url: String.t()}
  def select_random() do
    %{rows: rows, proxy: proxy} = GenServer.call(@client, {:get_random})

    Logger.info("Served image: \##{rows["id"]}")

    Collector.inc_images_served(1)

    # could possibly return nil? but shouldnt really
    rows |> normalize_image(proxy)
  end

  @spec select_by_idx(integer()) :: %{id: String.t(), idx: integer(), url: String.t()} | nil
  def select_by_idx(idx) do
    %{rows: rows, proxy: proxy} = GenServer.call(@client, {:get_by_id, idx})

    Collector.inc_images_served(1)

    rows |> normalize_image(proxy)
  end

  @spec select_all(integer()) :: list(%{id: String.t(), idx: integer(), url: String.t()})
  def select_all(page) do
    %{rows: rows, proxy: proxy} = GenServer.call(@client, {:get_all, page})

    Collector.inc_images_served(Enum.count(rows))

    rows
    |> Enum.map(&normalize_image(&1, proxy))
  end

  # priv
  defp normalize_image(%{"url" => path, "id" => idx}, proxy) do
    id =
      path
      |> String.split("/")
      |> List.last()
      |> String.split("_")
      |> List.first()

    %{
      idx: idx,
      id: id,
      url: "#{proxy}/#{path}"
    }
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
