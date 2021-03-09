defmodule CadastreDev.Source.Countries do
  @moduledoc false

  alias CadastreDev.API
  alias CadastreDev.Source

  @behaviour Source

  @json_path "data/iso_3166-1.json"
  @po_dir "iso_3166-1"

  @impl Source
  def msgid_per_id do
    case API.download_json(@json_path) do
      %{"3166-1" => list} when is_list(list) ->
        list
        |> Enum.flat_map(fn
          %{"alpha_2" => id, "name" => msgid} -> [{id, msgid}]
          _ -> []
        end)
        |> Enum.into(%{})

      json ->
        raise "#{@json_path} has wrong format:\n#{inspect(json)}"
    end
  end

  @impl Source
  def msgstr_per_msgid_per_lang, do: Source.load_msgstr_per_msgid_per_lang(@po_dir)
end
