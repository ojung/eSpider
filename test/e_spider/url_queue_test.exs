defmodule URLQueueTest do
  use ExUnit.Case, async: false
  import ESpider.URLQueue

  test "push single url" do
    push_url("url")
    assert read_url == "url"
  end

  test "push individual urls first in first out" do
    :ok = push_url("first")
    :ok = push_url("second")
    :ok = push_url("third")
    assert read_url == "first"
    assert read_url == "second"
    assert read_url == "third"
  end

  test "push bulk urls first in first out" do
    :ok = push_urls(["first", "second", "third"])
    assert read_url == "first"
    assert read_url == "second"
    assert read_url == "third"
  end
end
