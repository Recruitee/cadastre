defmodule Cadastre.Backend.Subdivisions do
  @moduledoc false

  alias Cadastre.Subdivision

  subdivisions_path = Application.app_dir(:cadastre, "priv/subdivisions.erl")

  @external_resource subdivisions_path

  name_per_id_per_country_id = subdivisions_path |> File.read!() |> :erlang.binary_to_term()

  name_per_id_per_country_id
  |> Enum.each(fn {country_id, name_per_id} ->
    subdivision_per_id =
      name_per_id
      |> Enum.map(fn {id, name} ->
        {id, Macro.escape(%Subdivision{country_id: country_id, id: id, name: name})}
      end)

    subdivisions = subdivision_per_id |> Enum.map(fn {_, subdivision} -> subdivision end)
    subdivision_ids = subdivision_per_id |> Enum.map(fn {id, _} -> id end)

    def subdivision_ids(unquote(country_id)), do: unquote(subdivision_ids)
    def subdivisions(unquote(country_id)), do: unquote(subdivisions)

    subdivision_per_id
    |> Enum.each(fn {id, subdivision} ->
      def subdivision(unquote(country_id), unquote(id)), do: unquote(subdivision)
    end)
  end)

  name_per_id_per_country_id
  |> Enum.each(fn {country_id, _} ->
    downcased_country_id = country_id |> String.downcase()

    def subdivision_ids(unquote(downcased_country_id)), do: subdivision_ids(unquote(country_id))
    def subdivisions(unquote(downcased_country_id)), do: subdivisions(unquote(country_id))
    def subdivision(unquote(downcased_country_id), id), do: subdivision(unquote(country_id), id)
  end)

  name_per_id_per_country_id
  |> Enum.flat_map(fn {_, name_per_id} ->
    name_per_id |> Enum.map(fn {id, _} -> id end)
  end)
  |> Enum.uniq()
  |> Enum.map(&{&1, String.downcase(&1)})
  |> Enum.reject(fn {id, downcased_id} -> id == downcased_id end)
  |> Enum.each(fn {id, downcased_id} ->
    def subdivision(country_id, unquote(downcased_id)), do: subdivision(country_id, unquote(id))
  end)

  def subdivision_ids(_), do: []
  def subdivisions(_), do: []
  def subdivision(_country_id, _subdivision_id), do: nil
end
