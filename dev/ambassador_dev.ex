defmodule AmbassadorDev do
  @moduledoc """
  The module is not compiled to the library.
  It's used for downloading ISO data:
  - ISO_639-2 (languages),
  - ISO_3166-1 (countries),
  - ISO_3166-2 (subdivisions).
  """

  alias AmbassadorDev.PO
  alias AmbassadorDev.Source.Countries
  alias AmbassadorDev.Source.Languages
  alias AmbassadorDev.Source.Subdivisions

  def update_data do
    subdivisions_msgstr_per_msgid_per_lang_task =
      Countries |> Task.async(:msgstr_per_msgid_per_lang, [])

    countries_msgstr_per_msgid_per_lang_task =
      Countries |> Task.async(:msgstr_per_msgid_per_lang, [])

    languages_msgstr_per_msgid_per_lang_task =
      Languages |> Task.async(:msgstr_per_msgid_per_lang, [])

    subdivisions_msgid_per_id_task = Subdivisions |> Task.async(:msgid_per_id, [])
    countries_msgid_per_id_task = Countries |> Task.async(:msgid_per_id, [])
    languages_msgid_per_id_task = Languages |> Task.async(:msgid_per_id, [])

    languages_override_per_lang_per_id = Languages.override_per_lang_per_id()
    countries_override_per_lang_per_id = Countries.override_per_lang_per_id()
    subdivisions_override_per_lang_per_id = Subdivisions.override_per_lang_per_id()

    languages_msgid_per_id = languages_msgid_per_id_task |> await()
    write_languages(languages_msgid_per_id, languages_override_per_lang_per_id)

    countries_msgid_per_id = countries_msgid_per_id_task |> await()
    write_countries(countries_msgid_per_id, countries_override_per_lang_per_id)

    subdivisions_msgid_per_id =
      subdivisions_msgid_per_id_task |> await() |> filter_by_countries(countries_msgid_per_id)

    write_subdivisions(subdivisions_msgid_per_id, subdivisions_override_per_lang_per_id)

    PO.write(
      "languages",
      languages_msgid_per_id,
      await(languages_msgstr_per_msgid_per_lang_task),
      languages_override_per_lang_per_id
    )

    PO.write(
      "countries",
      countries_msgid_per_id,
      await(countries_msgstr_per_msgid_per_lang_task),
      countries_override_per_lang_per_id
    )

    PO.write(
      "subdivisions",
      subdivisions_msgid_per_id,
      await(subdivisions_msgstr_per_msgid_per_lang_task),
      subdivisions_override_per_lang_per_id
    )
  end

  defp write_languages(msgid_per_id, override_per_lang_per_id) do
    overrided_msg_id_per_id(msgid_per_id, override_per_lang_per_id) |> write_json("languages")
  end

  defp write_countries(msgid_per_id, override_per_lang_per_id) do
    overrided_msg_id_per_id(msgid_per_id, override_per_lang_per_id) |> write_json("countries")
  end

  defp write_subdivisions(msgid_per_id, override_per_lang_per_id) do
    overrided_msg_id_per_id(msgid_per_id, override_per_lang_per_id)
    |> Enum.reduce(%{}, fn
      {<<country_id::binary-size(2), "-", subdivision_id::binary>>, msgid}, acc ->
        acc
        |> Map.update(country_id, %{subdivision_id => msgid}, &Map.put(&1, subdivision_id, msgid))
    end)
    |> write_json("subdivisions")
  end

  defp filter_by_countries(subdivisions_msgid_per_id, countries_msgid_per_id) do
    country_ids = countries_msgid_per_id |> Map.keys()

    subdivisions_msgid_per_id
    |> Enum.filter(fn {<<country_id::binary-size(2), "-", _::binary>>, _} ->
      country_id in country_ids
    end)
    |> Enum.into(%{})
  end

  defp overrided_msg_id_per_id(msgid_per_id, override_per_lang_per_id) do
    msgid_per_id
    |> Enum.map(fn {id, msgid} ->
      updated_msgid = override_per_lang_per_id |> Map.get(id, %{}) |> Map.get("en", msgid)
      {id, updated_msgid}
    end)
    |> Enum.into(%{})
  end

  defp write_json(map, domain) do
    "priv/#{domain}.json" |> File.write!(Jason.encode_to_iodata!(map))
  end

  defp await(task), do: Task.await(task, 120_000)
end
