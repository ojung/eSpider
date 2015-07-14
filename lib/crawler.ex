defmodule Crawler do
  @moduledoc false

  import HyperlinkHelpers
  require Logger
  use Calendar

  def loop(cache) do
    me = self
    #TODO: Add {:ok, :timeout} and {:warning, message} handlers
    receive do
      {:links, links} ->
        links |> Enum.each(&Task.start(__MODULE__, :crawl, [&1, cache, me, 0]))
        loop(cache)
      {:error, [message: message]} ->
        Logger.warn("received error: " <> message)
        loop(cache)
      _ -> loop(cache)
    end
  end

  def crawl(_, _, _, 5), do: :ok
  def crawl(url, cache, parent, tries) do
    if (url |> should_crawl?(cache)) do
      case url |> HTTPHandler.fetch(0) do
        {:ok, res} ->
          extract_content(url, res, cache)
          send(parent, {:links, get_links(res.body)})
        {:error, :timeout} ->
          crawl(url, cache, parent, tries + 1)
        {:error, exception} ->
          send(parent, {:error, exception})
        _ ->
          Logger.debug("Can not crawl: " <> url)
      end
    end
  end

  defp should_crawl?(url, cache) do
    case cache |> Cache.get(url) do
      {:ok, :undefined} -> true
      {:ok, existing} ->
        %{:ttl => ttl} = existing |> :erlang.binary_to_term
        ttl < DateTime.now_utc
      _ -> false
    end
  end

  defp extract_content(url, response, cache) do
    tags = ["h1", "h2", "h3", "h4", "h5"]
    headlines = tags |> Enum.map(&Floki.find(response.body, &1))
    one_day_in_seconds = 60 * 60 * 24
    Cache.put(cache, url, %{
      :ttl => DateTime.now_utc |> DateTime.advance!(one_day_in_seconds),
      :headlines => headlines
    })
    Logger.info("Website crawled: " <> url)
  end

  def get_links(body) do
    Floki.find(body, "a")
    |> Enum.map(&get_href/1)
    |> Enum.map(&get_root/1)
    |> Enum.filter(&valid_link?/1)
    |> Enum.uniq
  end
end
