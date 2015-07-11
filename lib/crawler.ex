defmodule Crawler do
  require Logger
  use Calendar

  def loop(cache) do
    me = self
    receive do
      {:links, links} ->
        #TODO Maybe introduce a queue to avoid crawling a site double
        Enum.filter(links, &should_crawl?(&1, cache))
        |> Enum.each(&Task.start(__MODULE__, :crawl, [&1, cache, me, 0]))
        loop(cache)
      {:error, [message: message]} ->
        Logger.warn("received error: " <> message)
        loop(cache)
      {:error, _} ->
        Logger.warn("received error")
        loop(cache)
      _ -> loop(cache)
    end
  end

  defp should_crawl?(url, cache) do
    case Cache.get(cache, url) do
      {:ok, :undefined} -> true
      {:ok, existing} ->
        #%{:ttl => ttl} = :erlang.binary_to_term(existing)
        #TODO: Find out why date comparison doesn't work as expected
        false
      _ -> false
    end
  end

  def crawl(_, _, _, 5) do end
  def crawl(url, cache, parent, tries) do
    case fetch(url) do
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

  defp extract_content(url, response, cache) do
    headlines = Floki.find(response.body, "h1")
    Cache.put_if_not_exists(cache, url, %{
      :ttl => DateTime.now_utc |> DateTime.advance!(1),
      :headlines => headlines
    })
    Logger.info("Website crawled: " <> url)
  end

  #TODO: Seperate HTTP handling into own module
  defp fetch(url) do
    try do
      HTTPotion.get(url, [headers: ["Accept": "text/html"]])
    rescue
      #TODO: Only match timeout error
      _ in HTTPotion.HTTPError ->
        {:error, :timeout}
    else
      response ->
        handle_response(response, url)
    end
  end

  defp handle_response(response, url) do
    if (response != nil) do
      if (response.status_code == 301 || response.status_code == 302) do
        follow_redirect(response, url)
      else
        {:ok, response}
      end
    else
      {:error, [message: "Request failed with unknown reason: " <> url]}
    end
  end

  defp follow_redirect(response, url) do
    new_location = response.headers[:Location]
    #TODO: Only follow redirect if should_crawl? == true
    if (new_location != nil && is_absolute?(new_location)) do
      Logger.debug("Following redirect: " <> new_location <> " from: " <> url)
      fetch(remove_params(new_location))
    end
  end

  def get_links(body) do
    Floki.find(body, "a")
    |> Enum.map(&get_href/1)
    |> Enum.filter(&is_absolute?/1)
    |> Enum.filter(&no_mailto?/1)
    |> Enum.map(&remove_params/1)
    |> Enum.uniq
  end

  defp get_href({_, attrs, _}) do
    {_, href} = Enum.find attrs, {"", ""}, fn({attr, _}) ->
      attr == "href"
    end
    href
  end

  defp remove_params(url) do
    List.first(String.split(url, "?", trim: true))
  end

  defp no_mailto?(url), do: not String.contains?(url, "mailto")

  defp is_absolute?(url), do: String.contains?(url, ["http", "https"])
end
