defmodule ESpider.Crawler do
  @moduledoc false

  import ESpider.HTTP.HyperlinkHelpers

  alias ESpider.Cache
  alias ESpider.URLQueue

  require Logger

  use Calendar

  def start_link do
    Task.Supervisor.start_link(name: __MODULE__)
  end

  def crawl_seeds do
    [
      "https://www.reddit.com/",
      "https://news.ycombinator.com",
      "https://www.github.com",
      "https://stackoverflow.com",
      "https://wikipedia.org"
    ] |> Enum.each(&crawl/1)
  end

  def loop(max_crawlers) do
    num_crawlers = __MODULE__ |> Task.Supervisor.children |> Enum.count
    url = URLQueue.read_url
    unless (num_crawlers >= max_crawlers || url == nil) do
      __MODULE__ |> Task.Supervisor.start_child(__MODULE__, :crawl, [url])
    end
    loop(max_crawlers)
  end

  def crawl(url) do
    if (Cache.should_crawl?(url)) do
      headers = %{"Accept" => "text/html"}
      options = [hackney: [follow_redirect: true, max_redirect: 3]]
      case HTTPoison.get(url, headers, options) do
        {:ok, res} -> handle_response(res, url)
        {:error, %HTTPoison.Error{id: _, reason: :connect_timeout}} ->
          URLQueue.push_url(url)
      end
    end
  end

  defp handle_response(res, url) do
    extract_content(url, res)
    one_day_in_seconds = 60 * 60 * 24
    ttl = DateTime.now_utc |> DateTime.advance!(one_day_in_seconds)
    Cache.put(url, ttl)
    URLQueue.push_urls(get_links(res.body))
  end

  defp get_links(body) do
    Floki.find(body, "a")
    |> Enum.map(&get_href/1)
    |> Enum.filter(&valid_link?/1)
    |> Enum.uniq
  end

  defp extract_content(url, _response) do
    #tags = ["h1", "h2", "h3", "h4", "h5"]
    #headlines = tags |> Enum.map(&Floki.find(response.body, &1))
    Logger.info("Website crawled: " <> url)
    #Logger.info(inspect(headlines))
  end
end
