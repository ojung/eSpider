defmodule ESpider.URLQueue do
  @moduledoc false

  import List, only: [first: 1, delete_at: 2, delete: 2]

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def push_url(url) do
    Agent.update(__MODULE__, fn(queue) ->
      if (not Enum.member?(queue, url)) do
        queue ++ [url]
      else
        queue
      end
    end)
  end

  def push_urls(urls) do
    urls |> Enum.each(&push_url/1)
  end

  def read_url do
    Agent.get_and_update(__MODULE__, fn(queue) ->
      {first(queue), delete_at(queue, 0)}
    end)
  end

  def read_urls(n) do
    Agent.get_and_update(__MODULE__, fn(queue) ->
      items = queue |> Stream.take(n) |> Enum.to_list
      new_state = queue |> Enum.slice(n, length(queue))
      {items, new_state}
    end)
  end

  def size do
    Agent.get(__MODULE__, &length/1)
  end
end
