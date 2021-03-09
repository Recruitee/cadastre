defmodule Cadastre.MixProject do
  use Mix.Project

  @version "0.2.0"
  @description "A repository of languages, countries and country subdivisions from the iso-codes Debian package."
  @source_url "https://github.com/Recruitee/cadastre"

  def project do
    [
      name: "Cadastre",
      app: :cadastre,
      version: @version,
      elixir: "~> 1.8",
      description: @description,
      source_url: @source_url,
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
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  def docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      # These are the default files included in the package
      files: ["lib", "priv/data/*.etf", ".formatter.exs", "mix.exs", "README.md"],
      links: %{"GitHub" => @source_url},
      licenses: ["MIT"]
    ]
  end
end
