defmodule RestClient.Mixfile do
  use Mix.Project

  def project do
    [app: :rest_client,
     version: "0.0.1",
     description: "RestClient is a generic REST client library. It generates structs and functions
for use with APIs. ",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: [links: %{"GitHub" => "https://github.com/phikes/elixir-restclient"}]
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpotion]]
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
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.2"},
      {:httpotion, "~> 2.1.0"},
      {:inflex, "~> 1.4.1"},
      {:poison, "~> 1.5"},
      {:mock, "~> 0.1.1"}
    ]
  end
end
