defmodule ESpider.Supervisor do
  @moduledoc false

  import Supervisor.Spec

  alias ESpider.Cache
  alias ESpider.Crawler
  alias ESpider.URLQueue

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      supervisor(Crawler, []),
      worker(Cache, []),
      worker(URLQueue, [])
    ]
    supervise(children, [strategy: :one_for_one])
  end
end
