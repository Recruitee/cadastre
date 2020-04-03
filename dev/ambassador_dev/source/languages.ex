defmodule AmbassadorDev.Source.Languages do
  @moduledoc """
  The module is responsible for downloading languages data
  """

  alias AmbassadorDev.API
  alias AmbassadorDev.CSV
  alias AmbassadorDev.Source

  @behaviour Source

  @json_path "data/iso_639-2.json"
  @po_dir "iso_639-2"
  @allowed_ids Source.langs()

  @impl Source
  def msgid_per_id do
    case API.download_json(@json_path) do
      %{"639-2" => list} when is_list(list) ->
        list
        |> Enum.flat_map(fn
          %{"alpha_2" => id, "name" => msgid} when id in @allowed_ids -> [{id, msgid}]
          _ -> []
        end)
        |> Enum.into(%{})

      json ->
        raise "#{@json_path} has wrong format:\n#{inspect(json)}"
    end
  end

  @impl Source
  def msgstr_per_msgid_per_lang, do: Source.load_msgstr_per_msgid_per_lang(@po_dir)

  @impl Source
  def override_per_lang_per_id do
    msgstr_per_lang_per_id =
      "priv/dev/languages.csv"
      |> CSV.load()
      |> Enum.map(fn [id, name, native_name] -> {id, %{"en" => name, id => native_name}} end)
      |> Enum.into(%{})

    "languages"
    |> Source.override_per_lang_per_id_from_csv()
    |> Enum.reduce(msgstr_per_lang_per_id, fn {id, msgstr_per_lang}, acc ->
      acc |> Map.update(id, msgstr_per_lang, &Map.merge(&1, msgstr_per_lang))
    end)
  end
end
