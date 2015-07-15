defmodule ESpider do
  def main(args) do

    seeds = [
      "https://www.reddit.com/",
      "https://news.ycombinator.com",
      "https://www.github.com",
      "https://stackoverflow.com",
      "https://wikipedia.com"
    ]
    {:ok, cache} = ESpider.Cache.start_link
    {:ok, p} = Task.start(ESpider.Crawler, :loop, [cache])
    Enum.each(seeds, &Task.start(ESpider.Crawler, :crawl, [&1, cache, p, 0]))

  end
end
