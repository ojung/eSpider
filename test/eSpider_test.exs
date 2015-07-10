defmodule ESpiderTest do
  use ExUnit.Case

  test "link extraction" do
    body = "<random><a href=\"http://google.com\">some link</a>"
    actual = ESpider.get_links(body)
    expected = ["http://google.com"]
    assert actual === expected
  end
end
