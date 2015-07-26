defmodule ESpider do
  @moduledoc false

  use Application

  def start(:normal, _) do
    ESpider.Supervisor.start_link
  end
end
