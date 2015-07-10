defmodule ESpider do
  def main(args) do
    url = "https://www.reddit.com/"
    {:ok, cache} = Cache.start_link
    {:ok, p} = Task.start(Crawler, :loop, [cache])
    Task.start(Crawler, :crawl, [url, cache, p, 0])
  end
end
