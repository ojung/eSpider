defmodule Crawler do
  require Logger

  def loop(cache) do
    me = self
    receive do
      {:links, links} ->
        Enum.each(links, &Task.start(__MODULE__, :crawl, [&1, cache, me, 0]))
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

  def crawl(url, _, parent, 3) do
    Logger.debug("Giving up after 3 tries for: " <> url)
  end
  def crawl(url, cache, parent, tries) do
    if (Cache.get(cache, url) == {:ok, :undefined}) do
      Cache.put_if_not_exists(cache, url, :erlang.now)
      case fetch(url) do
        {:ok, res} ->
          extract_content(res)
          send(parent, {:links, get_links(res.body)})
        {:error, :timeout} ->
          Cache.delete(cache, url)
          crawl(url, cache, parent, tries + 1)
        {:error, exception} ->
          Cache.delete(cache, url)
          send(parent, {:error, exception})
      end
    else
      Logger.debug("Skipping existing url: " <> url)
    end
  end

  defp extract_content(response) do
    [{_, _, [title]}] = Floki.find(response.body, "title")
    Logger.info("Website crawled: " <> title)
  end

  defp fetch(url) do
    try do
      HTTPotion.get(url)
    rescue
      ex in HTTPotion.HTTPError ->
        {:error, :timeout}
    else
      value ->
        if (value != nil) do
          {:ok, value}
        else
          {:error, [message: "Request failed with unknown reason: " <> url]}
        end
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

  defp remove_params(url) do
    List.first(String.split(url, "?", trim: true))
  end

  defp no_mailto?(url), do: not String.contains?(url, "mailto")

  defp get_href({_, attrs, _}) do
    {_, href} = Enum.find attrs, {"", ""}, fn({attr, _}) ->
      attr == "href"
    end
    href
  end

  defp is_absolute?(url), do: String.contains?(url, ["http", "https"])
end
