defmodule ExponentServerSdk.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exponent_server_sdk,
      version: "0.2.0",
      elixir: "~> 1.7.2",
      name: "ExponentServerSdk",
      description: "Exponent Push Notification API library for Elixir",
      source_url: "https://github.com/rdrop/exponent-server-sdk-elixir",
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger, :httpoison, :poison]]
  end

  defp deps do
    [
      {:httpoison, ">= 1.2.0"},
      {:poison, "~> 3.1.0"},
      {:dialyze, "~> 0.2.1", only: [:dev, :test]},
      {:credo, "~> 0.10.0", only: [:dev, :test]},
      {:mock, "~> 0.3.2", only: :test},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test]},
      {:inch_ex, ">= 0.0.0", only: [:dev, :test]}
    ]
  end

  def docs do
    [
      readme: "README.md",
      main: ExponentServerSdk
    ]
  end

  defp package do
    [
      maintainers: ["rdrop"],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/rdrop/exponent-server-sdk-elixir.git"
      }
    ]
  end
end
