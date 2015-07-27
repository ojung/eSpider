defmodule ESpider.Mixfile do
  use Mix.Project

  def project do
    [
      app: :eSpider,
      version: "0.0.1",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      escript: [main_module: ESpider],
      test_coverage: [tool: ExCoveralls],
      deps: deps
    ]
  end

  def application do
    [
      mod: {ESpider, []},
      applications: [
        :logger,
        :httpoison,
        :kafka_ex
      ]
    ]
  end

  defp deps do
    [
      {:calendar, "~> 0.7.0"},
      {:dialyze, "~> 0.2.0"},
      {:dogma, "~> 0.0.2"},
      {:eredis, github: "wooga/eredis"},
      {:excoveralls, "~> 0.3", only: :test},
      {:floki, "~> 0.3.2"},
      {:hackney, github: "benoitc/hackney", tag: "1.3.0", override: true},
      {:httpoison, "~> 0.7.0"},
      {:kafka_ex, "~> 0.1.0"},
      {:mock, "~> 0.1.1"},
      {:uuid, "~> 1.0.0"}
    ]
  end
end
