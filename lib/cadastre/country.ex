defmodule Cadastre.Country do
  @moduledoc """

  Country implementation
  """
  alias Cadastre.Backend
  alias Cadastre.Language

  @enforce_keys [:id, :name]
  defstruct [:id, :name]

  @type id :: <<_::16>>
  @type t :: %__MODULE__{id: id, name: Cadastre.msgid()}

  @doc """
  Returns all countries

  ## Examples
  ```
  iex> Cadastre.Country.all() |> Enum.take(3)
  [
    %Cadastre.Country{id: "AD", name: "Andorra"},
    %Cadastre.Country{id: "AE", name: "United Arab Emirates"},
    %Cadastre.Country{id: "AF", name: "Afghanistan"}
  ]

  iex> Cadastre.Language.all() |> Enum.count()
  140
  ```
  """
  @spec all :: [t]
  def all, do: apply(Backend, :countries, [])

  @doc """
  Return all ids (ISO_3166-1)

  ## Examples
  ```
  iex> Cadastre.Country.ids() |> Enum.take(10)
  ["AD", "AE", "AF", "AG", "AI", "AL", "AM", "AO", "AQ", "AR"]
  ```
  """
  @spec ids :: [id]
  def ids, do: apply(Backend, :country_ids, [])

  @doc """
  Returns `%Cadastre.Country{}` for valid `id`.
  Returns `nil` for invalid `id`.

  ## Examples
  ```
  iex> Cadastre.Country.new("NL")
  %Cadastre.Country{id: "NL", name: "Netherlands"}

  iex> Cadastre.Country.new("nl")
  %Cadastre.Country{id: "NL", name: "Netherlands"}

  iex> Cadastre.Country.new("xx")
  nil
  ```
  """
  @spec new(id | any) :: t | nil
  def new(id), do: apply(Backend, :country, [id])

  @doc """
  Returns country name translation for `locale`

  ## Examples
  ```
  iex> Cadastre.Country.new("NL") |> Cadastre.Country.name("be")
  "Нідэрланды"

  iex> Cadastre.Country.new("NL") |> Cadastre.Country.name(":)")
  "Netherlands"

  iex> Cadastre.Country.name("something wrong", "be")
  nil
  ```
  """
  @spec name(t, Language.id()) :: String.t()
  def name(country, locale)
  def name(%__MODULE__{name: name}, locale), do: name |> Backend.translate("countries", locale)
  def name(_, _), do: nil
end
