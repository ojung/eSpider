defmodule ESpider.HTTP.HyperlinkHelpers do
  @moduledoc false

  def get_href({_, attrs, _}) do
    {_, href} = Enum.find attrs, {"", ""}, fn({attr, _}) ->
      attr == "href"
    end
    href
  end

  def get_root(url) do
    matches = Regex.run(~r/https?\:\/\/([^\/:?#]+)/, url)
    if (matches) do
      matches |> List.first
    end
  end

  def valid_link?(url) do
    syntax_correct?(url) && no_media?(url)
  end

  defp syntax_correct?(url) do
    regex = ~r/^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#&\/\/=]*)/
    url != nil && Regex.match?(regex, url)
  end

  defp no_media?(url) do
    not (url |> String.contains?([
      ".png", ".jpg", ".JPG", ".gifv", ".mp4", ".swf", ".wmv", ".gif"
    ]))
  end
end
