defmodule ESpider.CacheTest do
  alias ESpider.Cache

  use ExUnit.Case, async: true
  use Calendar

  @cache_name ESpider.Cache

  setup _context do
    {:ok, direct_redis} = :eredis.start_link
    {:ok, _} = direct_redis |> :eredis.q(["FLUSHALL"])
    :ok
  end

  test "store values by key" do
    assert(Cache.get("key1") == :undefined)
    Cache.put("key1", "value1")
    assert(Cache.get("key1") == "value1")
  end

  test "delete values by key"  do
    Cache.put("del", "eteme")
    Cache.delete("del")
    assert(Cache.get("del") == :undefined)
  end

  test "should crawl"  do
    Cache.put("key1", DateTime.now_utc |> DateTime.advance!(-1))
    assert(Cache.should_crawl?("key1"))
  end

  test "should not crawl"  do
    ttl = 60 * 60
    Cache.put("key1", DateTime.now_utc |> DateTime.advance!(ttl))
    assert(not Cache.should_crawl?("key1"))
  end
end
