defmodule ESpider do
  def start(:normal, _) do

    seeds = [
      "https://www.reddit.com/",
      "https://news.ycombinator.com",
      "https://www.github.com",
      "https://stackoverflow.com",
      "https://wikipedia.com"
    ]
    {:ok, cache} = ESpider.Cache.start_link

  end
end
