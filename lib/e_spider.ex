defmodule ESpider do
  @moduledoc false

  import Supervisor.Spec

  use Application

  alias ESpider.Cache
  alias ESpider.URLQueue
  alias ESpider.Crawler

  @cache_name ESpider.Cache

  def start(:normal, _) do
    children = [
      worker(Cache, []),
      supervisor(Crawler, []),
      worker(URLQueue, [])
    ]
    Supervisor.start_link(children, [strategy: :one_for_one])
  end

  def crawl_seeds do
    [
      "https://www.reddit.com/",
      "https://news.ycombinator.com",
      "https://www.github.com",
      "https://stackoverflow.com",
      "https://wikipedia.com"
    ]
    |> Enum.each(fn(url) -> Crawler.crawl!(url) end)
  end
end
