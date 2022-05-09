defmodule Ganyu.Database.Postgres do
  @moduledoc """
  `Ganyu.Database.Postgres` is a module that provides connection to Postgres.
  """

  use GenServer

  alias Ganyu.Metrics.Collector

  require Logger

  @client :ganyu_postgres_client
  @page_size 10

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: @client)
  end

  @impl true
  def init(_args) do
    {:ok, client} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "ganyu",
        port: 5432
      )

    client |> init_call()

    {:ok, %{client: client}}
  end

  defp init_call(client) do
    query = "CREATE TABLE IF NOT EXISTS images (id SERIAL PRIMARY KEY, url VARCHAR(255) NOT NULL)"

    case Postgrex.query(client, query, []) do
      {:ok, res} ->
        res = res.messages |> List.first()

        Logger.debug("#{res.severity}: #{res.message}")
    end
  end

  @impl true
  def handle_call({:get_all, page}, _from, state) do
    query = "SELECT id,url FROM images ORDER BY id ASC LIMIT #{@page_size} OFFSET $1"

    {:ok, result} = Postgrex.query(state[:client], query, [page * @page_size - 10])

    {:reply, result |> result_to_maps, state}
  end

  @impl true
  def handle_call({:get_random}, _from, state) do
    query = "SELECT id,url FROM images ORDER BY RANDOM() LIMIT 1"

    {:ok, result} = Postgrex.query(state[:client], query, [])

    {:reply, result |> result_to_maps, state}
  end

  @impl true
  def handle_call({:get_by_id, id}, _from, state) do
    query = "SELECT id,url FROM images WHERE id = ($1)"

    {:ok, result} = Postgrex.query(state[:client], query, [id])

    {:reply, result |> result_to_maps, state}
  end

  @impl true
  def handle_call({:exists, url}, _from, state) do
    query = "SELECT id,url FROM images WHERE url = ($1)"

    {:ok, result} = Postgrex.query(state[:client], query, [url])

    {:reply, result |> result_to_maps, state}
  end

  @impl true
  def handle_cast(_event, state) do
    {:noreply, state}
  end

  # public api with pretty formatting

  @proxy_path Application.get_env(:ganyu, :proxy_path, "https://pximg.pxseu.com")

  def select_random(proxy \\ nil) do
    response = GenServer.call(@client, {:get_random}) |> List.first()

    Collector.inc_images_served(1)

    response |> normalize_image(proxy)
  end

  def select_all(page, proxy \\ nil) do
    rows = GenServer.call(@client, {:get_all, page})

    Collector.inc_images_served(Enum.count(rows))

    rows
    |> Enum.map(&normalize_image(&1, proxy))
  end

  def select_by_idx(idx, proxy \\ nil) do
    response = GenServer.call(@client, {:get_by_id, idx}) |> List.first()

    Collector.inc_images_served(1)

    response |> normalize_image(proxy)
  end

  def data_includes(path) do
    real_path =
      if(path |> String.starts_with?(@proxy_path)) do
        path
        |> String.replace(@proxy_path, "")
      else
        path
      end

    GenServer.call(@client, {:exists, real_path})
  end

  # priv

  defp normalize_image(res, _) when is_nil(res), do: nil

  defp normalize_image(%{"url" => path, "id" => idx}, proxy) do
    id =
      path
      |> String.split("/")
      |> List.last()
      |> String.split("_")
      |> List.first()

    path = "#{use_proxy(proxy)}/#{path}"

    %{
      idx: idx,
      id: id,
      url: path
    }
  end

  defp use_proxy(nil), do: @proxy_path
  defp use_proxy(proxy), do: proxy

  defp result_to_maps(%Postgrex.Result{columns: _names, rows: nil}), do: []

  defp result_to_maps(%Postgrex.Result{columns: names, rows: rows}) do
    Enum.map(rows, fn row -> row_to_map(names, row) end)
  end

  defp row_to_map(names, vals) do
    Stream.zip(names, vals)
    |> Enum.into(Map.new())
  end
end
