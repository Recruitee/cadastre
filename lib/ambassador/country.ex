defmodule Ambassador.Country do
  @moduledoc """

  Country implementation
  """
  alias Ambassador.Backend
  alias Ambassador.Language

  @enforce_keys [:id, :name]
  defstruct [:id, :name]

  @type id :: <<_::16>>
  @type t :: %__MODULE__{id: id, name: Ambassador.msgid()}

  @doc """
  Returns all countries

  ## Examples

  iex> Ambassador.Country.all() |> Enum.take(3)
  [
    %Ambassador.Country{id: "AD", name: "Andorra"},
    %Ambassador.Country{id: "AE", name: "United Arab Emirates"},
    %Ambassador.Country{id: "AF", name: "Afghanistan"}
  ]

  iex> Ambassador.Language.all() |> Enum.count()
  140
  """
  @spec all :: [t]
  def all, do: apply(Backend, :countries, [])

  @doc """
  Return all ids (ISO_3166-1)

  ## Examples

  iex> Ambassador.Country.ids() |> Enum.take(10)
  ["AD", "AE", "AF", "AG", "AI", "AL", "AM", "AO", "AQ", "AR"]
  """
  @spec ids :: [id]
  def ids, do: apply(Backend, :country_ids, [])

  @doc """
  Returns %Ambassador.Country{} for valid `id`.
  Returns `nil` for invalid `id`.

  ## Examples

  iex> Ambassador.Country.new("NL")
  %Ambassador.Country{id: "NL", name: "Netherlands"}

  iex> Ambassador.Country.new("nl")
  %Ambassador.Country{id: "NL", name: "Netherlands"}

  iex> Ambassador.Country.new("xx")
  nil
  """
  @spec new(id | any) :: t | nil
  def new(id), do: apply(Backend, :country, [id])

  @doc """
  Returns country name translation for `locale`

  ## Examples

  iex> Ambassador.Country.new("NL") |> Ambassador.Country.name("be")
  "Нідэрланды"

  iex> Ambassador.Country.new("NL") |> Ambassador.Country.name(":)")
  "Netherlands"

  iex> Ambassador.Country.name("something wrong", "be")
  nil
  """
  @spec name(t, Language.id()) :: String.t()
  def name(%__MODULE__{name: name}, locale), do: name |> Backend.translate("countries", locale)
  def name(_, _), do: nil
end
