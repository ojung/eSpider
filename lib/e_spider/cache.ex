defmodule ESpider.Cache do
  @moduledoc false

  use Calendar
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get(key) do
    __MODULE__ |> GenServer.call({:get, key})
  end

  def put(key, value) do
    __MODULE__ |> GenServer.cast({:put, {key, value}})
  end

  def delete(key) do
    __MODULE__ |> GenServer.cast({:del, key})
  end

  def should_crawl?(url) do
    case get(url) do
      :undefined -> true
      binary ->
        ttl = binary |> :erlang.binary_to_term
        ttl < DateTime.now_utc
      _ -> false
    end
  end

  def init(_) do
    {:ok, redis} = :eredis.start_link
    {:ok, redis}
  end

  def handle_call({:get, key}, _from, redis) do
    {:ok, value} = redis |> :eredis.q(["GET", key])
    {:reply, value, redis}
  end

  def handle_cast({:put, {key, value}}, redis) do
    {:ok, _} = redis |> :eredis.q(["SET", key, value])
    {:noreply, redis}
  end

  def handle_cast({:del, key}, redis) do
    {:ok, _} = redis |> :eredis.q(["DEL", key])
    {:noreply, redis}
  end
end
