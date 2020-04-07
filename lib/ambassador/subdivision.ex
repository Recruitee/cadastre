defmodule Ambassador.Subdivision do
  @moduledoc """
  Subdivision implementation
  """
  alias Ambassador.Backend
  alias Ambassador.Country
  alias Ambassador.Language

  @enforce_keys [:id, :country_id, :name]
  defstruct [:id, :country_id, :name]

  @type id :: String.t()
  @type t :: %__MODULE__{id: id, country_id: Country.id(), name: Ambassador.msgid()}

  @doc """
  Returns subdivisions for country.
  Returns empty list for invalid argument.

  ## Examples

  iex> Ambassador.Subdivision.all("SL")
  [
    %Ambassador.Subdivision{country_id: "SL", id: "E", name: "Eastern"},
    %Ambassador.Subdivision{country_id: "SL", id: "N", name: "Northern"},
    %Ambassador.Subdivision{country_id: "SL", id: "S", name: "Southern (Sierra Leone)"},
    %Ambassador.Subdivision{country_id: "SL", id: "W", name: "Western Area (Freetown)"}
  ]

  iex> "SL" |> Ambassador.Country.new() |> Ambassador.Subdivision.all()
  [
    %Ambassador.Subdivision{country_id: "SL", id: "E", name: "Eastern"},
    %Ambassador.Subdivision{country_id: "SL", id: "N", name: "Northern"},
    %Ambassador.Subdivision{country_id: "SL", id: "S", name: "Southern (Sierra Leone)"},
    %Ambassador.Subdivision{country_id: "SL", id: "W", name: "Western Area (Freetown)"}
  ]

  iex> Ambassador.Subdivision.all("XX")
  []

  iex> Ambassador.Subdivision.all(nil)
  []
  """
  @spec all(Country.t() | Country.id() | any) :: [t]
  def all(country_or_country_id) do
    country_or_country_id |> country_id() |> Backend.subdivisions()
  end

  @doc """
  Returns subdivision ids for country.
  Returns empty list for invalid argument.

  ## Examples

  iex> Ambassador.Subdivision.ids("SL")
  ["E", "N", "S", "W"]

  iex> "SL" |> Ambassador.Country.new() |> Ambassador.Subdivision.ids()
  ["E", "N", "S", "W"]

  iex> Ambassador.Subdivision.ids("XX")
  []

  iex> Ambassador.Subdivision.ids(nil)
  []
  """
  @spec ids(Country.t() | Country.id() | any) :: [id]
  def ids(country_or_country_id) do
    country_or_country_id |> country_id() |> Backend.subdivision_ids()
  end

  @doc """
  Returns `%Ambassador.Subdivision{}` for valid country/country_id and id.
  Returns `nil` for invalid country/country_id and id.

  ## Examples

  iex> Ambassador.Subdivision.new("SL", "W")
  %Ambassador.Subdivision{country_id: "SL", id: "W", name: "Western Area (Freetown)"}

  iex> "SL" |> Ambassador.Country.new() |> Ambassador.Subdivision.new( "W")
  %Ambassador.Subdivision{country_id: "SL", id: "W", name: "Western Area (Freetown)"}

  iex> Ambassador.Subdivision.new("NL", "W")
  nil

  iex> Ambassador.Subdivision.new("SL", "X")
  nil

  iex> Ambassador.Subdivision.new(nil, nil)
  nil
  """
  @spec new(Country.t() | Country.id() | any, id | any) :: t | nil
  def new(country_or_country_id, id) do
    country_or_country_id |> country_id() |> Backend.subdivision(id)
  end

  @doc """
  Returns subdivision name translation for `locale`

  ## Examples

  iex> Ambassador.Subdivision.new("SL", "W") |> Ambassador.Subdivision.name("be")
  "Заходняя вобласць"

  iex> Ambassador.Subdivision.new("SL", "W") |> Ambassador.Subdivision.name(":)")
  "Western Area (Freetown)"

  iex> Ambassador.Subdivision.name("something wrong", "be")
  nil
  """
  @spec name(t, Language.id()) :: String.t()
  def name(%__MODULE__{name: name}, locale), do: name |> Backend.translate("subdivisions", locale)
  def name(_, _), do: nil

  defp country_id(%Country{id: country_id}), do: country_id
  defp country_id(country_id), do: country_id
end
