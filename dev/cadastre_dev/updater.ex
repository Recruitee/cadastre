defmodule CadastreDev.Updater do
  @moduledoc false

  def update_data do
    update_domain("languages")
    update_domain("countries")
    update_domain("subdivisions")
  end

  defp update_domain(domain) do
    domain
    |> load_data()
    |> deep_merge(load_override(domain))
    |> to_sorted_list()
    |> write_data(domain)
  end

  def deep_merge(map1, map2) do
    map1
    |> Map.merge(map2, fn
      _, v1, v2 when is_map(v1) and is_map(v2) -> deep_merge(v1, v2)
      _, _, v2 -> v2
    end)
  end

  defp to_sorted_list(map) do
    map
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn
      {k, v} when is_map(v) -> {k, to_sorted_list(v)}
      any -> any
    end)
  end

  defp load_data(domain), do: domain |> load_domain("data")

  defp load_override(domain), do: domain |> load_domain("overrides")

  defp load_domain(domain, folder) do
    Application.app_dir(:cadastre, "priv/dev/#{folder}/#{domain}.json")
    |> File.read!()
    |> Jason.decode!()
  end

  defp write_data(data, domain) do
    binary = data |> :erlang.term_to_binary()
    Application.app_dir(:cadastre, "priv/data/#{domain}.etf") |> File.write!(binary)
  end
end
