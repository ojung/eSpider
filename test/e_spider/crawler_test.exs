defmodule ESpider.CrawlerTest do
  import ESpider.Crawler
  import Mock

  use ExUnit.Case, async: true

  @some_url "http://test.de"
  @another_url "http://anotherlink.com"
  @old_location "http://old-location.com"

  setup do
    {:ok, cache} = ESpider.Cache.start_link
    {:ok, _} = cache |> :eredis.q(["FLUSHALL"])
    {:ok, cache: cache}
  end

  test "extract links", %{cache: cache} do
    html = ~s"""
      <html><body>
      <a href=#{@some_url}>asd</a>
      <a href=#{@another_url}>asd</a>
      </html></body>
    """
    with_mock HTTPotion, [get: &TestHelpers.respond_body(&1, &2, html)] do
      expected = {:links, [@some_url, @another_url]}
      assert(crawl("http://example.com", cache, 0) == expected)
    end
  end

  test "error handling", %{cache: cache} do
    with_mock HTTPotion, [
      get: &TestHelpers.redirect_response(&1, &2, @old_location)
    ] do
      expected = {:error, [
          message: "Possible redirect loop detected for: #{@old_location}"
        ]}
      assert(crawl(@old_location, cache, 0) == expected)
    end
  end
end
