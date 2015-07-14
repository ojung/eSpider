defmodule HTTPHandler do
  @moduledoc false

  import HyperlinkHelpers
  require Logger

  def fetch(url, 3) do
    {:error, [message: "Possible redirect loop detected for: " <> url]}
  end

  def fetch(url, tries) do
    try do
      HTTPotion.get(url, [headers: ["Accept": "text/html"]])
    rescue
      #TODO: Only match timeout error
      _ in HTTPotion.HTTPError ->
        {:error, :timeout}
    else
      response ->
        handle_response(response, url, tries + 1)
    end
  end

  defp handle_response(response, url, tries) do
    if (response != nil) do
      if (response.status_code == 301 || response.status_code == 302) do
        follow_redirect(response, url, tries)
      else
        {:ok, response}
      end
    else
      {:error, [message: "Request failed with unknown reason: " <> url]}
    end
  end

  defp follow_redirect(response, url, tries) do
    new_location = response.headers[:Location]
    #TODO: Only follow redirect if should_crawl? == true
    if (new_location != nil && new_location |> valid_link?) do
      Logger.debug("Following redirect: " <> new_location <> " from: " <> url)
      new_location |> fetch(tries)
    end
  end
end
