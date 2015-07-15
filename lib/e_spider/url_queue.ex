defmodule ESpider.URLQueue do
  import List, only: [first: 1, delete_at: 2]

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def push_url(url) do
    Agent.update(__MODULE__, fn(queue) -> queue ++ [url] end)
  end

  def read_url do
    Agent.get_and_update(__MODULE__, fn(queue) ->
      {first(queue), delete_at(queue, 0)}
    end)
  end
end

