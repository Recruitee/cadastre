defmodule Cadastre.MixProject do
  use Mix.Project

  @source_url "https://github.com/Recruitee/cadastre"
  @version "0.2.4"

  def project do
    [
      name: "Cadastre",
      app: :cadastre,
      version: @version,
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: extra_applications(Mix.env())
    ]
  end

  defp elixirc_paths(:dev), do: ["dev" | elixirc_paths(:prod)]
  defp elixirc_paths(_), do: ["lib"]

  defp extra_applications(:dev), do: [:inets | extra_applications(:prod)]
  defp extra_applications(_), do: [:logger]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Updating data
      {:gettext, ">= 0.0.0", only: :dev},
      {:jason, "~> 1.0", only: :dev},

      # Dev tools
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:credo, "~> 1.1", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  def docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end

  defp package do
    [
      description:
        "A repository of languages, countries and country " <>
          " subdivisions from the iso-codes Debian package.",
      maintainers: ["Serge Karpiesz"],
      files: ["lib", "priv/data/*.etf", ".formatter.exs", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
