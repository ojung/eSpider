defmodule ESpider.Crawler do
  @moduledoc false

    #TODO don't crawl recursively until the system is satuated but instead
    #use a queue to schedule urls to be crawled.
    #Add urls to the queue in an asynchronous fashion.

  import ESpider.HTTP.HyperlinkHelpers
  require Logger
  use Calendar

  def crawl(_, _, _, 5), do: :ok
  def crawl(url, cache, parent, tries) do
    if (url |> should_crawl?(cache)) do
      case url |> ESpider.HTTP.Handler.fetch(0) do
        {:ok, res} ->
          extract_content(url, res)
          one_day_in_seconds = 60 * 60 * 24
          ttl = DateTime.now_utc |> DateTime.advance!(one_day_in_seconds)
          ESpider.Cache.put(cache, url, ttl)
          {:links, get_links(res.body)}
        {:error, :timeout} -> crawl(url, cache, parent, tries + 1)
        {:error, exception} -> {:error, exception}
        _ -> Logger.debug("Can not crawl: " <> url)
      end
    end
  end

  defp get_links(body) do
    Floki.find(body, "a")
    |> Enum.map(&get_href/1)
    |> Enum.filter(&valid_link?/1)
    |> Enum.uniq
  end

  defp extract_content(url, response) do
    tags = ["h1", "h2", "h3", "h4", "h5"]
    headlines = tags |> Enum.map(&Floki.find(response.body, &1))
    Logger.info("Website crawled: " <> url)
    Logger.info(inspect(headlines))
  end
end
