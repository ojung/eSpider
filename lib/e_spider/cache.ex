defmodule ESpider.Cache do
  def start_link do
    :eredis.start_link
  end

  def get(cache, key) do
    :eredis.q(cache, ["GET", key])
  end

  def put(cache, key, value) do
    :eredis.q(cache, ["SET", key, value])
  end

  def put_if_not_exists(cache, key, value) do
    :eredis.q(cache, ["SETNX", key, value])
  end

  def delete(cache, key) do
    :eredis.q(cache, ["DEL", key])
  end
end

