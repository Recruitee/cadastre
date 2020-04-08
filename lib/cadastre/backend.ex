defmodule Cadastre.Backend do
  @moduledoc false

  alias Cadastre.Country
  alias Cadastre.I18n
  alias Cadastre.Language
  alias Cadastre.Subdivision

  languages_data =
    "priv/languages.json"
    |> File.read!()
    |> Jason.decode!()
    |> Enum.sort_by(fn {id, _} -> id end)

  countries_data =
    "priv/countries.json"
    |> File.read!()
    |> Jason.decode!()
    |> Enum.sort_by(fn {id, _} -> id end)

  def languages do
    unquote(
      Enum.map(languages_data, fn {id, name} -> Macro.escape(%Language{id: id, name: name}) end)
    )
  end

  def language_ids, do: unquote(Enum.map(languages_data, fn {id, _} -> id end))

  languages_data
  |> Enum.each(fn {id, name} ->
    language = Macro.escape(%Language{id: id, name: name})

    def language(unquote(id)), do: unquote(language)
    def language(unquote(String.upcase(id))), do: unquote(language)
  end)

  def language(_), do: nil

  def countries do
    unquote(
      Enum.map(countries_data, fn {id, name} -> Macro.escape(%Country{id: id, name: name}) end)
    )
  end

  def country_ids, do: unquote(Enum.map(countries_data, fn {id, _} -> id end))

  countries_data
  |> Enum.each(fn {id, name} ->
    country = Macro.escape(%Country{id: id, name: name})

    def country(unquote(id)), do: unquote(country)
    def country(unquote(String.downcase(id))), do: unquote(country)
  end)

  def country(_), do: nil

  "priv/subdivisions.json"
  |> File.read!()
  |> Jason.decode!()
  |> Enum.sort_by(fn {country_id, subdivisions_map} ->
    subdivisions_data = subdivisions_map |> Enum.sort_by(fn {id, _} -> id end)

    subdivisions =
      subdivisions_data
      |> Enum.map(fn {id, name} ->
        Macro.escape(%Subdivision{country_id: country_id, id: id, name: name})
      end)

    subdivision_ids = subdivisions_data |> Enum.map(fn {id, _} -> id end)

    [country_id, String.downcase(country_id)]
    |> Enum.each(fn arg ->
      def subdivisions(unquote(arg)), do: unquote(subdivisions)
      def subdivision_ids(unquote(arg)), do: unquote(subdivision_ids)
    end)

    subdivisions_data
    |> Enum.each(fn {id, name} ->
      def subdivision(unquote(country_id), unquote(id)) do
        unquote(Macro.escape(%Subdivision{country_id: country_id, id: id, name: name}))
      end

      def subdivision(unquote(String.downcase(country_id)), unquote(id)) do
        unquote(Macro.escape(%Subdivision{country_id: country_id, id: id, name: name}))
      end
    end)
  end)

  def translate(msgid, domain, locale) do
    I18n |> Gettext.with_locale(locale, fn -> I18n |> Gettext.dgettext(domain, msgid) end)
  end

  def subdivisions(_), do: []
  def subdivision_ids(_), do: []
  def subdivision(_, _), do: nil
end
