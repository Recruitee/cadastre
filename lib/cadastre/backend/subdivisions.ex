defmodule Cadastre.Backend.Subdivisions do
  @moduledoc false

  alias Cadastre.Subdivision

  subdivisions_path = Application.app_dir(:cadastre, "priv/subdivisions.erl")

  @external_resource subdivisions_path

  subdivisions_data =
    subdivisions_path
    |> File.read!()
    |> :erlang.binary_to_term()

  Enum.each(subdivisions_data, fn {country_id, subdivisions_data} ->
    subdivision_ids = subdivisions_data |> Enum.map(fn {id, _} -> id end)

    [country_id, String.downcase(country_id)]
    |> Enum.each(fn arg ->
      def subdivision_ids(unquote(arg)), do: unquote(subdivision_ids)
    end)
  end)

  def subdivision_ids(_), do: []

  Enum.each(subdivisions_data, fn {country_id, subdivisions_data} ->
    subdivisions =
      subdivisions_data
      |> Enum.map(fn {id, name} ->
        Macro.escape(%Subdivision{country_id: country_id, id: id, name: name})
      end)

    [country_id, String.downcase(country_id)]
    |> Enum.each(fn arg ->
      def subdivisions(unquote(arg)), do: unquote(subdivisions)
    end)
  end)

  def subdivisions(_), do: []

  @subdivision subdivisions_data
               |> Enum.flat_map(fn {country_id, subdivisions} ->
                 Enum.map(subdivisions, fn {id, name} ->
                   {{String.upcase(country_id), String.upcase(id)},
                    %Subdivision{country_id: country_id, id: id, name: name}}
                 end)
               end)
               |> Map.new()

  def subdivision(country_id, subdivision_id)
      when is_binary(country_id) and is_binary(subdivision_id) do
    Map.get(@subdivision, {String.upcase(country_id), String.upcase(subdivision_id)})
  end

  def subdivision(_country_id, _subdivision_id), do: nil
end
