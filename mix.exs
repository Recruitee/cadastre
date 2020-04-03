defmodule Ambassador.MixProject do
  use Mix.Project

  def project do
    [
      app: :ambassador,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      # Dev tools
      {:dialyxir, "~> 1.0", only: :dev, runtime: false}
    ]
  end
end
