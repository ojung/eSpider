defmodule ESpider.CrawlerTest do
  import ESpider.Crawler
  import Mock

  use ExUnit.Case, async: true

  setup do
    {:ok, cache} = ESpider.Cache.start_link
    {:ok, _} = cache |> :eredis.q(["FLUSHALL"])
    {:ok, cache: cache}
  end

  test "extract links", %{cache: cache} do
    html = ~s"""
      <html><body>
      <a href="http://test.de">asd</a>
      <a href="http://anotherlink.com">asd</a>
      </html></body>
    """
    with_mock HTTPotion, [get: &TestHelpers.respond_body(&1, &2, html)] do
      expected = {:links, ["http://test.de", "http://anotherlink.com"]}
      assert(crawl("http://example.com", cache, 0) == expected)
    end
  end

  test "error handling", %{cache: cache} do
    with_mock HTTPotion, [
      get: &TestHelpers.redirect_response(&1, &2, "http://old-location.com")
    ] do
      expected = {:error, [
          message: "Possible redirect loop detected for: http://old-location.com"
        ]}
      assert(crawl("http://old-location.com", cache, 0) == expected)
    end
  end
end
