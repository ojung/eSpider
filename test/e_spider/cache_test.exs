defmodule ESpider.CacheTest do
  import ESpider.Cache

  use ExUnit.Case, async: true
  use Calendar

  setup do
    {:ok, cache} = start_link
    {:ok, _} = cache |> :eredis.q(["FLUSHALL"])
    {:ok, cache: cache}
  end

  test "store values by key", %{cache: cache} do
    assert(cache |> get("key1") == {:ok, :undefined})
    {:ok, _} = cache |> put("key1", "value1")
    assert(cache |> get("key1") == {:ok, "value1"})
  end

  test "delete values by key", %{cache: cache} do
    {:ok, _} = cache |> put("del", "eteme")
    {:ok, _} = cache |> delete("del")
    assert(cache |> get("del") == {:ok, :undefined})
  end

  test "should crawl", %{cache: cache} do
    {:ok, _} = cache |> put("key1", DateTime.now_utc |> DateTime.advance!(-1))
    assert(cache |> should_crawl?("key1"))
  end

  test "should not crawl", %{cache: cache} do
    ttl = 60 * 60
    {:ok, _} = cache |> put("key1", DateTime.now_utc |> DateTime.advance!(ttl))
    assert(not should_crawl?(cache, "key1"))
  end
end
