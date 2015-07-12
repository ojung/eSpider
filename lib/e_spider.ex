defmodule ESpider do
  def main(args) do

    seeds = [
      "https://www.reddit.com/",
      "https://news.ycombinator.com",
      "https://www.github.com",
      "https://stackoverflow.com",
      "https://wikipedia.com"
    ]
    {:ok, cache} = Cache.start_link
    {:ok, p} = Task.start(Crawler, :loop, [cache])
    Enum.each(seeds, &Task.start(Crawler, :crawl, [&1, cache, p, 0]))

  end
end
