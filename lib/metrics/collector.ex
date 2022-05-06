defmodule Ganyu.Metrics.Collector do
  @moduledoc """
  `Ganyu.Metrics.Collector` is a package for collecting metric data.
  """

  use GenServer

  @client :ganyu_metrics_collector

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: @client)
  end

  @impl true
  def init(_args) do
    {:ok,
     %{
       created_at: System.system_time(:millisecond),
       ganyu_total_requests: 0,
       ganyu_2xx_requests: 0,
       ganyu_4xx_requests: 0,
       ganyu_5xx_requests: 0,
       images_served: 0
     }}
  end

  @impl true
  def handle_cast({:increment_images_served, ammount}, state) do
    ammount =
      cond do
        is_integer(ammount) -> ammount
        true -> 1
      end

    {:noreply, Map.update(state, :images_served, 0, &(&1 + ammount))}
  end

  @impl true
  def handle_cast({:increment_request, key}, state) do
    state =
      state
      |> Map.update(key, 0, &(&1 + 1))
      |> Map.update(:ganyu_total_requests, 0, &(&1 + 1))

    {:noreply, state}
  end

  @impl true
  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  # pubs

  def inc_requests(status) do
    type =
      cond do
        status >= 200 && status < 300 ->
          :ganyu_2xx_requests

        status >= 400 && status < 500 ->
          :ganyu_4xx_requests

        status >= 500 ->
          :ganyu_5xx_requests
      end

    GenServer.cast(@client, {:increment_request, type})
  end

  def inc_images_served(ammount) do
    GenServer.cast(@client, {:increment_images_served, ammount})
  end

  def get_state() do
    GenServer.call(@client, {:get_state})
  end
end
