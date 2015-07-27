defmodule ESpider.Supervisor do
  @moduledoc false

  @supervisor :espider

  import Supervisor.Spec

  alias ESpider.Cache
  alias ESpider.Crawler
  alias ESpider.URLQueue

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @supervisor)
  end

  def init(:ok) do
    children = [
      worker(Cache, []),
      supervisor(Crawler, []),
      supervisor(URLQueue, [])
    ]
    supervise(children, [strategy: :one_for_one])
  end
end
