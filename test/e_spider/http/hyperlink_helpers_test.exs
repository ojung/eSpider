defmodule HyperlinkHelpersTest do
  use ExUnit.Case, async: true

  import ESpider.HTTP.HyperlinkHelpers

  test "get href from a html anchor element" do
    html = ~s(<a href="http://somethi.ng/resource?param=1">asd</a>)
    parsed = Floki.parse(html)
    assert(get_href(parsed) == "http://somethi.ng/resource?param=1")
  end

  test "get root of an url" do
    url = "http://somethi.ng/resource?param=1"
    assert(get_root(url) == "http://somethi.ng")
  end

  test "link validitiy predicate" do
    valid = "http://somethi.ng/resource?param=1&param2=2"
    invalid = ["/resource", "http://someimage.com/pic.jpg", "htp://asd.fg"]
    assert(valid_link?(valid))
    invalid |> Enum.each(fn(url) -> assert(not valid_link?(url)) end)
  end
end
