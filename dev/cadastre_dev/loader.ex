defmodule CadastreDev.Loader do
  @moduledoc false

  # The module is not compiled to the library.
  # It's used for downloading ISO data:
  # - ISO_639-2 (languages),
  # - ISO_3166-1 (countries),
  # - ISO_3166-2 (subdivisions).

  alias CadastreDev.Source.Countries
  alias CadastreDev.Source.Languages
  alias CadastreDev.Source.Subdivisions

  def load_data do
    allowed_language_ids = load_languages()
    allowed_country_ids = load_countries(allowed_language_ids)
    load_subdivisions(allowed_language_ids, allowed_country_ids)
  end

  def load_languages do
    allowed_languages = load_allowed_langugaes()
    allowed_language_ids = allowed_languages |> Map.keys()
    msgid_per_id = Languages.msgid_per_id()
    msgstr_per_en_per_lang = Languages.msgstr_per_msgid_per_lang()

    allowed_languages
    |> Map.new(fn {id, [en, native]} ->
      value =
        msgstr_per_en_per_lang
        |> build_translations(Map.get(msgid_per_id, id), allowed_language_ids)
        |> Map.put("en", en)
        |> Map.put(id, native)

      {id, value}
    end)
    |> write_json("languages")

    allowed_languages |> Map.keys()
  end

  def load_countries(allowed_language_ids) do
    msgstr_per_en_per_lang = Countries.msgstr_per_msgid_per_lang()
    en_per_id = Countries.msgid_per_id()

    en_per_id
    |> Map.new(fn {id, en} ->
      value = msgstr_per_en_per_lang |> build_translations(en, allowed_language_ids)
      {id, value}
    end)
    |> write_json("countries")

    en_per_id |> Map.keys()
  end

  def load_subdivisions(allowed_language_ids, allowed_country_ids) do
    msgstr_per_en_per_lang =
      Subdivisions.msgstr_per_msgid_per_lang()
      |> Map.new(fn {lang, msgstr_per_msgid} ->
        msgstr_per_msgid
        |> Map.new(fn {msgid, msgstr} ->
          {delete_dagger_symbol(msgid), delete_dagger_symbol(msgstr)}
        end)
        |> then(& {lang, &1})
      end)

    Subdivisions.msgid_per_id()
    |> Enum.reduce(%{}, fn {id, en}, acc ->
      with <<country_id::binary-size(2), "-", subdivision_id::binary>> <- id,
           true <- country_id in allowed_country_ids do
        value = msgstr_per_en_per_lang |> build_translations(delete_dagger_symbol(en), allowed_language_ids)

        acc
        |> Map.update(country_id, %{subdivision_id => value}, &Map.put(&1, subdivision_id, value))
      end
    end)
    |> write_json("subdivisions")
  end

  defp build_translations(msgstr_per_en_per_lang, en, allowed_language_ids) do
    msgstr_per_en_per_lang
    |> Enum.reduce(%{}, fn {lang, msgstr_per_en}, acc ->
      with true <- lang in allowed_language_ids,
           {:ok, msgstr} <- msgstr_per_en |> Map.fetch(en),
           false <- msgstr == en do
        acc |> Map.put(lang, msgstr)
      else
        _ -> acc
      end
    end)
    |> Map.put("en", en)
  end

  defp delete_dagger_symbol(msgstr) do
    msgstr |> String.replace("†", "") |> String.trim()
  end

  defp write_json(map, domain) do
    iodata = map |> Jason.encode_to_iodata!(pretty: true)
    Application.app_dir(:cadastre, "priv/dev/data/#{domain}.json") |> File.write!(iodata)
  end

  defp load_allowed_langugaes do
    Application.app_dir(:cadastre, "priv/dev/allowed_languages.json")
    |> File.read!()
    |> Jason.decode!()
  end
end
