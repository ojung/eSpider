defmodule ESpider.Crawler do
  @moduledoc false

  import ESpider.HTTP.HyperlinkHelpers
  import ESpider.HTTP.Handler

  alias ESpider.Cache
  alias ESpider.URLQueue

  require Logger

  use Calendar

  def start_link do
    Task.Supervisor.start_link(name: __MODULE__)
  end

  def crawl!(url) do
    __MODULE__ |> Task.Supervisor.start_child(__MODULE__, :crawl, [url])
  end

  def crawl(url) do
    Logger.warn("Crawling away...")
    if (Cache.should_crawl?(url)) do
      {:ok, res} = fetch(url, 0)
      extract_content(url, res)
      one_day_in_seconds = 60 * 60 * 24
      ttl = DateTime.now_utc |> DateTime.advance!(one_day_in_seconds)
      Cache.put(url, ttl)
      get_links(res.body) |> Enum.each(&URLQueue.push_url/1)
    end
  end

  defp get_links(body) do
    Floki.find(body, "a")
    |> Enum.map(&get_href/1)
    |> Enum.filter(&valid_link?/1)
    |> Enum.uniq
  end

  defp extract_content(url, response) do
    #tags = ["h1", "h2", "h3", "h4", "h5"]
    #headlines = tags |> Enum.map(&Floki.find(response.body, &1))
    #Logger.info("Website crawled: " <> url)
    #Logger.info(inspect(headlines))
  end
end
