defmodule CadastreDev do
  @moduledoc false

  # The module is not compiled to the library.
  # It's used for downloading ISO data:
  # - ISO_639-2 (languages),
  # - ISO_3166-1 (countries),
  # - ISO_3166-2 (subdivisions).

  alias CadastreDev.PO
  alias CadastreDev.Source.Countries
  alias CadastreDev.Source.Languages
  alias CadastreDev.Source.Subdivisions

  def update_data do
    subdivisions_msgstr_per_msgid_per_lang_task =
      Subdivisions |> Task.async(:msgstr_per_msgid_per_lang, [])

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
    country_ids = write_countries(countries_msgid_per_id, countries_override_per_lang_per_id)

    subdivisions_msgid_per_id =
      subdivisions_msgid_per_id_task |> await() |> filter_by_countries(country_ids)

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
    msgid_per_id
    |> overrided_msg_id_per_id(override_per_lang_per_id)
    |> Enum.sort_by(fn {id, _} -> id end)
    |> write_erl("languages")
  end

  defp write_countries(msgid_per_id, override_per_lang_per_id) do
    msg_id_per_id = msgid_per_id
    |> overrided_msg_id_per_id(override_per_lang_per_id)
    |> Enum.sort_by(fn {id, _} -> id end)

    write_erl(msg_id_per_id, "countries")

    Enum.map(msg_id_per_id, &elem(&1, 0))
  end

  defp write_subdivisions(msgid_per_id, override_per_lang_per_id) do
    msgid_per_id
    |> overrided_msg_id_per_id(override_per_lang_per_id)
    |> Enum.reduce(%{}, fn
      {<<country_id::binary-size(2), "-", subdivision_id::binary>>, msgid}, acc ->
        acc
        |> Map.update(country_id, [{subdivision_id, msgid}], &([{subdivision_id, msgid} | &1 ]))
    end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {country_id, subdivisions} ->
      {country_id, Enum.sort_by(subdivisions, &elem(&1, 1))}
    end)
    |> write_erl("subdivisions")
  end

  defp filter_by_countries(subdivisions_msgid_per_id, country_ids) do
    subdivisions_msgid_per_id
    |> Enum.filter(fn {<<country_id::binary-size(2), "-", _::binary>>, _} ->
      country_id in country_ids
    end)
    |> Enum.into(%{})
  end

  defp overrided_msg_id_per_id(msgid_per_id, override_per_lang_per_id) do
    [Map.keys(msgid_per_id) | Map.keys(override_per_lang_per_id)]
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.map(fn id ->
      msgid =
        override_per_lang_per_id
        |> Map.get(id, %{})
        |> Map.get_lazy("en", fn -> msgid_per_id |> Map.get(id) end)

      {id, msgid}
    end)
    |> Enum.into(%{})
  end

  defp write_erl(map, domain) do
    "priv/#{domain}.erl" |> File.write!(:erlang.term_to_binary(map))
  end

  defp await(task), do: Task.await(task, 120_000)
end
