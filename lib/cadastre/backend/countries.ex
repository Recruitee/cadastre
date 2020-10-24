defmodule Cadastre.Backend.Countries do
  @moduledoc false

  alias Cadastre.Country

  countries_path = Application.app_dir(:cadastre, "priv/countries.erl")

  @external_resource countries_path

  name_per_id = countries_path |> File.read!() |> :erlang.binary_to_term()

  country_per_id =
    name_per_id |> Enum.map(fn {id, name} -> {id, Macro.escape(%Country{id: id, name: name})} end)

  countries = country_per_id |> Enum.map(fn {_, country} -> country end)
  ids = country_per_id |> Enum.map(fn {id, _} -> id end)

  def countries, do: unquote(countries)
  def country_ids, do: unquote(ids)

  country_per_id
  |> Enum.each(fn {id, country} ->
    def country(unquote(id)), do: unquote(country)
  end)

  ids
  |> Enum.each(fn id ->
    downcased_id = id |> String.downcase()
    def country(unquote(downcased_id)), do: country(unquote(id))
  end)

  def country(_), do: nil
end
