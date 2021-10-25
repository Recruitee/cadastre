defmodule Cadastre.Subdivision do
  @moduledoc """
  Subdivision implementation
  """
  alias Cadastre.Country
  alias Cadastre.Language

  @external_resource Application.app_dir(:cadastre, "priv/data/subdivisions.etf")

  @enforce_keys [:id, :country_id]
  defstruct [:id, :country_id]

  @type id :: String.t()
  @type t :: %__MODULE__{id: id, country_id: Country.id()}

  external_data = @external_resource |> File.read!() |> :erlang.binary_to_term()
  id_per_country_id = external_data |> Map.new(fn {k, v} -> {k, Enum.map(v, &elem(&1, 0))} end)

  @doc """
  Returns all subdivision ids (ISO_3166-2) for country.
  Returns empty list for invalid argument.

  ## Examples
  ```
  iex> Cadastre.Subdivision.ids("SL")
  ["E", "N", "NW", "S", "W"]

  iex> "SL" |> Cadastre.Country.new() |> Cadastre.Subdivision.ids()
  ["E", "N", "NW", "S", "W"]

  iex> Cadastre.Subdivision.ids("XX")
  []

  iex> Cadastre.Subdivision.ids(nil)
  []
  ```
  """
  @spec ids(Country.t() | Country.id() | any) :: [id]
  def ids(country_or_country_id) do
    country_or_country_id |> get_country_id() |> get_ids()
  end

  @doc """
  Returns subdivisions for country.
  Returns empty list for invalid argument.

  ## Examples
  ```
  iex> Cadastre.Subdivision.all("SL")
  [
    %Cadastre.Subdivision{country_id: "SL", id: "E"},
    %Cadastre.Subdivision{country_id: "SL", id: "N"},
    %Cadastre.Subdivision{country_id: "SL", id: "NW"},
    %Cadastre.Subdivision{country_id: "SL", id: "S"},
    %Cadastre.Subdivision{country_id: "SL", id: "W"}
  ]

  iex> "SL" |> Cadastre.Country.new() |> Cadastre.Subdivision.all()
  [
    %Cadastre.Subdivision{country_id: "SL", id: "E"},
    %Cadastre.Subdivision{country_id: "SL", id: "N"},
    %Cadastre.Subdivision{country_id: "SL", id: "NW"},
    %Cadastre.Subdivision{country_id: "SL", id: "S"},
    %Cadastre.Subdivision{country_id: "SL", id: "W"}
  ]

  iex> Cadastre.Subdivision.all("XX")
  []

  iex> Cadastre.Subdivision.all(nil)
  []
  ```
  """
  @spec all(Country.t() | Country.id() | any) :: [t]
  def all(country_or_country_id) do
    country_id = country_or_country_id |> get_country_id()
    country_id |> get_ids() |> Enum.map(&%__MODULE__{id: &1, country_id: country_id})
  end

  @doc """
  Returns `%Cadastre.Subdivision{}` for valid country/country_id and id.
  Returns `nil` for invalid country/country_id and id.

  ## Examples
  ```
  iex> Cadastre.Subdivision.new("SL", "W")
  %Cadastre.Subdivision{country_id: "SL", id: "W"}

  iex> Cadastre.Subdivision.new("sl", "w")
  %Cadastre.Subdivision{country_id: "SL", id: "W"}

  iex> "SL" |> Cadastre.Country.new() |> Cadastre.Subdivision.new("W")
  %Cadastre.Subdivision{country_id: "SL", id: "W"}

  iex> Cadastre.Subdivision.new("NL", "W")
  nil

  iex> Cadastre.Subdivision.new("SL", "X")
  nil

  iex> Cadastre.Subdivision.new(nil, nil)
  nil
  ```
  """
  @spec new(Country.t() | Country.id() | any, id | any) :: t | nil
  def new(country_or_country_id, id) when is_binary(id) do
    country_id = country_or_country_id |> get_country_id()
    ids = country_id |> get_ids()

    cond do
      id in ids ->
        %__MODULE__{country_id: country_id, id: id}

      ids != [] ->
        id = id |> String.upcase()
        if id in ids, do: %__MODULE__{country_id: country_id, id: id}

      true ->
        nil
    end
  end

  def new(_, _), do: nil

  @doc """
  Returns subdivision name translation for `locale`

  ## Examples
  ```
  iex> Cadastre.Subdivision.new("SL", "W") |> Cadastre.Subdivision.name("be")
  "Заходняя вобласць"

  iex> Cadastre.Subdivision.new("SL", "W") |> Cadastre.Subdivision.name(":)")
  "Western Area (Freetown)"

  iex> Cadastre.Subdivision.name("something wrong", "be")
  nil
  ```
  """
  @spec name(t, Language.id()) :: String.t()
  def name(subdivision, locale)

  external_data
  |> Enum.each(fn {country_id, subdivisions} ->
    subdivisions
    |> Enum.map(fn {subdivision_id, translations} ->
      translations = translations |> Map.new()
      en = translations |> Map.fetch!("en")

      def name(%__MODULE__{country_id: unquote(country_id), id: unquote(subdivision_id)}, locale) do
        unquote(Macro.escape(translations)) |> Map.get(locale, unquote(en))
      end
    end)
  end)

  def name(_, _), do: nil

  defp get_ids(country_id) do
    unquote(Macro.escape(id_per_country_id)) |> Map.get(country_id, [])
  end

  defp get_country_id(%Country{id: country_id}), do: country_id

  defp get_country_id(country_id) do
    country_id
    |> Country.new()
    |> case do
      %{id: id} -> id
      _ -> nil
    end
  end
end
