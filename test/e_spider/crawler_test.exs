defmodule ESpider.CrawlerTest do
  alias ESpider.Crawler
  alias ESpider.Cache
  import Mock

  use ExUnit.Case, async: false

  @some_url "http://test.de"
  @another_url "http://anotherlink.com"
  @old_location "http://old-location.com"

  setup _context do
    {:ok, redis} = :eredis.start_link
    {:ok, _} = redis |> :eredis.q(["FLUSHALL"])
    :ok
  end

  test "extract links" do
    html = ~s"""
      <html><body>
      <a href=#{@some_url}>asd</a>
      <a href=#{@another_url}>asd</a>
      </html></body>
    """
    with_mock HTTPotion, [get: &TestHelpers.respond_body(&1, &2, html)] do
      expected = {:links, [@some_url, @another_url]}
      assert(Task.await(Crawler.crawl!("http://example.com")) == expected)
    end
  end

  test "error handling" do
    with_mock HTTPotion, [
      get: &TestHelpers.redirect_response(&1, &2, @old_location)
    ] do
      expected = {:error, [
          message: "Possible redirect loop detected for: #{@old_location}"
        ]}
      assert(Task.await(Crawler.crawl!(@old_location)) == expected)
    end
  end
end
