defmodule Cadastre.Subdivision do
  @moduledoc """
  Subdivision implementation
  """
  alias Cadastre.Backend
  alias Cadastre.Country
  alias Cadastre.Language

  @enforce_keys [:id, :country_id, :name]
  defstruct [:id, :country_id, :name]

  @type id :: String.t()
  @type t :: %__MODULE__{id: id, country_id: Country.id(), name: Cadastre.msgid()}

  @doc """
  Returns subdivisions for country.
  Returns empty list for invalid argument.

  ## Examples
  ```
  iex> Cadastre.Subdivision.all("SL")
  [
    %Cadastre.Subdivision{country_id: "SL", id: "E", name: "Eastern"},
    %Cadastre.Subdivision{country_id: "SL", id: "N", name: "Northern"},
    %Cadastre.Subdivision{country_id: "SL", id: "S", name: "Southern (Sierra Leone)"},
    %Cadastre.Subdivision{country_id: "SL", id: "W", name: "Western Area (Freetown)"}
  ]

  iex> "SL" |> Cadastre.Country.new() |> Cadastre.Subdivision.all()
  [
    %Cadastre.Subdivision{country_id: "SL", id: "E", name: "Eastern"},
    %Cadastre.Subdivision{country_id: "SL", id: "N", name: "Northern"},
    %Cadastre.Subdivision{country_id: "SL", id: "S", name: "Southern (Sierra Leone)"},
    %Cadastre.Subdivision{country_id: "SL", id: "W", name: "Western Area (Freetown)"}
  ]

  iex> Cadastre.Subdivision.all("XX")
  []

  iex> Cadastre.Subdivision.all(nil)
  []
  ```
  """
  @spec all(Country.t() | Country.id() | any) :: [t]
  def all(country_or_country_id) do
    country_or_country_id |> country_id() |> Backend.subdivisions()
  end

  @doc """
  Returns all subdivision ids (ISO_3166-2) for country.
  Returns empty list for invalid argument.

  ## Examples
  ```
  iex> Cadastre.Subdivision.ids("SL")
  ["E", "N", "S", "W"]

  iex> "SL" |> Cadastre.Country.new() |> Cadastre.Subdivision.ids()
  ["E", "N", "S", "W"]

  iex> Cadastre.Subdivision.ids("XX")
  []

  iex> Cadastre.Subdivision.ids(nil)
  []
  ```
  """
  @spec ids(Country.t() | Country.id() | any) :: [id]
  def ids(country_or_country_id) do
    country_or_country_id |> country_id() |> Backend.subdivision_ids()
  end

  @doc """
  Returns `%Cadastre.Subdivision{}` for valid country/country_id and id.
  Returns `nil` for invalid country/country_id and id.

  ## Examples
  ```
  iex> Cadastre.Subdivision.new("SL", "W")
  %Cadastre.Subdivision{country_id: "SL", id: "W", name: "Western Area (Freetown)"}

  iex> "SL" |> Cadastre.Country.new() |> Cadastre.Subdivision.new( "W")
  %Cadastre.Subdivision{country_id: "SL", id: "W", name: "Western Area (Freetown)"}

  iex> Cadastre.Subdivision.new("NL", "W")
  nil

  iex> Cadastre.Subdivision.new("SL", "X")
  nil

  iex> Cadastre.Subdivision.new(nil, nil)
  nil
  ```
  """
  @spec new(Country.t() | Country.id() | any, id | any) :: t | nil
  def new(country_or_country_id, id) do
    country_or_country_id |> country_id() |> Backend.subdivision(id)
  end

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
  def name(%__MODULE__{name: name}, locale), do: name |> Backend.translate("subdivisions", locale)
  def name(_, _), do: nil

  defp country_id(%Country{id: country_id}), do: country_id
  defp country_id(country_id), do: country_id
end
