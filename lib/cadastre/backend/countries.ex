defmodule Cadastre.Backend.Countries do
  @moduledoc false

  alias Cadastre.Country

  countries_path = Application.app_dir(:cadastre, "priv/countries.erl")

  @external_resource countries_path

  countries_data =
    countries_path
    |> File.read!()
    |> :erlang.binary_to_term()

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
end
