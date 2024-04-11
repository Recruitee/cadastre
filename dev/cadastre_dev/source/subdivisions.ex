defmodule CadastreDev.Source.Subdivisions do
  @moduledoc false

  alias CadastreDev.API
  alias CadastreDev.Source

  @behaviour Source

  @json_path "data/iso_3166-2.json"
  @po_dir "iso_3166-2"

  @depths "priv/dev/subdivision_depths.json" |> File.read!() |> Jason.decode!()

  @impl Source
  def msgid_per_id do
    case API.download_json(@json_path) do
      %{"3166-2" => list} when is_list(list) ->
        list = list |> Enum.filter(&valid?/1) |> Enum.map(&Map.put_new(&1, "parent", nil))

        list
        |> fetch_country_ids()
        |> Enum.map(&fetch_subdivisions(list, &1, Map.get(@depths, &1, 1)))
        |> List.flatten()
        |> Enum.into(%{})

      json ->
        raise "#{@json_path} has wrong format:\n#{inspect(json)}"
    end
  end

  @impl Source
  def msgstr_per_msgid_per_lang, do: Source.load_msgstr_per_msgid_per_lang(@po_dir)

  defp fetch_country_ids(list) do
    list
    |> Enum.map(fn
      %{"code" => code} ->
        String.slice(code, 0..1)

      _ ->
        nil
    end)
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
  end

  defp fetch_subdivisions(list, country_id, depth, parent \\ nil)

  defp fetch_subdivisions(_list, _country_id, 0 = _depth, _parent), do: []

  defp fetch_subdivisions(list, country_id, depth, parent) do
    list
    |> Enum.filter(&(String.starts_with?(&1["code"], country_id) and &1["parent"] == parent))
    |> Enum.map(fn %{"code" => id, "name" => msgid} ->
      subdivision = {id, msgid}
      children = fetch_subdivisions(list, country_id, depth - 1, id)
      [subdivision | children]
    end)
  end

  defp valid?(%{"code" => _code, "name" => _name}), do: true
  defp valid?(_), do: false
end
