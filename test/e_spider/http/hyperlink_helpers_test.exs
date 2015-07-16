defmodule HyperlinkHelpersTest do
  use ExUnit.Case, async: true

  import ESpider.HTTP.HyperlinkHelpers

  @valid_url "http://somethi.ng/resource?param=1&param2=2"
  @invalid_urls ["/resource", "http://someimage.com/pic.jpg", "htp://asd.fg"]

  test "get href from a html anchor element" do
    html = ~s(<a href="#{@valid_url}">asd</a>)
    parsed = Floki.parse(html)
    assert(get_href(parsed) == @valid_url)
  end

  test "get root of an url" do
    assert(get_root(@valid_url) == "http://somethi.ng")
  end

  test "link validitiy predicate" do
    assert(valid_link?(@valid_url))
    @invalid_urls |> Enum.each(&(assert(not valid_link?(&1))))
  end
end
