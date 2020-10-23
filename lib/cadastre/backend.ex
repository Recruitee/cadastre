defmodule Cadastre.Backend do
  @moduledoc false

  alias Cadastre.I18n

  defdelegate languages, to: __MODULE__.Languages
  defdelegate language_ids, to: __MODULE__.Languages
  defdelegate language(language_id), to: __MODULE__.Languages

  defdelegate countries, to: __MODULE__.Countries
  defdelegate country_ids, to: __MODULE__.Countries
  defdelegate country(country_id), to: __MODULE__.Countries

  defdelegate subdivision(country_id, subdivision_id), to: __MODULE__.Subdivisions
  defdelegate subdivisions(country_id), to: __MODULE__.Subdivisions
  defdelegate subdivision_ids(country_id), to: __MODULE__.Subdivisions

  def translate(msgid, domain, locale) do
    I18n |> Gettext.with_locale(locale, fn -> I18n |> Gettext.dgettext(domain, msgid) end)
  end
end
