defmodule CacheTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, cache} = Cache.start_link
    {:ok, cache: cache}
  end

  test "store values by key", %{cache: cache} do
    {:ok, _} = :eredis.q(cache, ["DEL", "key1"])
    assert Cache.get(cache, "key1") == {:ok, :undefined}
    Cache.put(cache, "key1", "value1")
    assert Cache.get(cache, "key1") == {:ok, "value1"}
  end

  test "delete values by key", %{cache: cache} do
    Cache.put(cache, "del", "eteme")
    Cache.delete(cache, "del") == "eteme"
    assert Cache.get(cache, "del") == {:ok, :undefined}
  end
end
