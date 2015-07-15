defmodule ESpider.Cache do
  use Calendar

  def start_link do
    :eredis.start_link
  end

  def get(cache, key) do
    :eredis.q(cache, ["GET", key])
  end

  def put(cache, key, value) do
    :eredis.q(cache, ["SET", key, value])
  end

  def delete(cache, key) do
    :eredis.q(cache, ["DEL", key])
  end

  def should_crawl?(cache, url) do
    case cache |> get(url) do
      {:ok, :undefined} -> true
      {:ok, binary} ->
        ttl = binary |> :erlang.binary_to_term
        ttl < DateTime.now_utc
      _ -> false
    end
  end
end

