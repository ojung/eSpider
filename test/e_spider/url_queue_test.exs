defmodule URLQueueTest do
  use ExUnit.Case, async: true
  import ESpider.URLQueue

  test "push values" do
    assert read_url == nil
    url = "url"
    assert push_url(url) == :ok
    assert read_url == "url"
  end

  test "first in first out" do
    :ok = push_url("first")
    :ok = push_url("second")
    :ok = push_url("third")
    assert read_url == "first"
    assert read_url == "second"
    assert read_url == "third"
  end
end
