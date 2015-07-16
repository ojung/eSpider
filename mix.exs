defmodule ESpider.Mixfile do
  use Mix.Project

  def project do
    [app: :eSpider,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: ESpider],
     test_coverage: [tool: ExCoveralls],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {ESpider, []},
      applications: [:logger, :httpotion]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:calendar, "~> 0.7.0"},
      {:dialyze, "~> 0.2.0"},
      {:dogma, "~> 0.0.2"},
      {:eredis, github: "wooga/eredis"},
      {:excoveralls, "~> 0.3", only: :test},
      {:floki, "~> 0.3.2"},
      {:httpotion, "~> 2.1.0"},
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.1"},
      {:mock, "~> 0.1.1"}
    ]
  end
end
