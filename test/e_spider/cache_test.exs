defmodule CacheTest do
  use ExUnit.Case, async: true
  import ESpider.Cache

  setup do
    {:ok, cache} = start_link
    {:ok, cache: cache}
  end

  test "store values by key", %{cache: cache} do
    {:ok, _} = :eredis.q(cache, ["DEL", "key1"])
    assert(get(cache, "key1") == {:ok, :undefined})
    put(cache, "key1", "value1")
    assert(get(cache, "key1") == {:ok, "value1"})
  end

  test "delete values by key", %{cache: cache} do
    put(cache, "del", "eteme")
    assert({:ok, _} = delete(cache, "del"))
    assert(get(cache, "del") == {:ok, :undefined})
  end
end
