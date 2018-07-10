defmodule Engine.Viber.MixProject do
  use Mix.Project

  def project do
    [
      app: :viber_engine,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:agala, "~> 2.0"},
      {:httpoison, "~> 0.12"},
      {:poison, "~> 3.1"},
      {:construct, "~> 1.0"}
    ]
  end
end
