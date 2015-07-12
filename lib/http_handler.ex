defmodule HTTPHandler do
  @moduledoc false

  import HyperlinkHelpers
  require Logger

  def fetch(url) do
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
    if (new_location != nil && valid_link?(new_location)) do
      Logger.debug("Following redirect: " <> new_location <> " from: " <> url)
      fetch(remove_params(new_location))
    end
  end
end
