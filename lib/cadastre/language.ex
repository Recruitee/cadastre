defmodule Cadastre.Language do
  @moduledoc """
  Language implementation
  """
  alias Cadastre.Backend

  @enforce_keys [:id, :name]
  defstruct [:id, :name]

  @type id :: <<_::16>>
  @type t :: %__MODULE__{id: id, name: Cadastre.msgid()}

  @doc """
  Returns all languages

  ## Examples
  ```
  iex> Cadastre.Language.all() |> Enum.take(3)
  [
    %Cadastre.Language{id: "aa", name: "Afar"},
    %Cadastre.Language{id: "ab", name: "Abkhazian"},
    %Cadastre.Language{id: "af", name: "Afrikaans"}
  ]

  iex> Cadastre.Language.all() |> Enum.count()
  140
  ```
  """
  @spec all :: [t]
  def all, do: Backend.languages()

  @doc """
  Return all ids (ISO_639-2)

  ## Examples
  ```
  iex> Cadastre.Language.ids() |> Enum.take(10)
  ["aa", "ab", "af", "am", "an", "as", "av", "ba", "be", "bg"]
  ```
  """
  @spec ids :: [id]
  def ids, do: Backend.language_ids()

  @doc """
  Returns `%Cadastre.Language{}` for valid `id`.
  Returns `nil` for invalid `id`.

  ## Examples
  ```
  iex> Cadastre.Language.new("nl")
  %Cadastre.Language{id: "nl", name: "Dutch"}

  iex> Cadastre.Language.new("NL")
  %Cadastre.Language{id: "nl", name: "Dutch"}

  iex> Cadastre.Language.new("xx")
  nil
  ```
  """
  @spec new(id | any) :: t | nil
  def new(id), do: Backend.language(id)

  @doc """
  Returns language name translation for `locale`

  ## Examples
  ```
  iex> Cadastre.Language.new("nl") |> Cadastre.Language.name("be")
  "галандская"

  iex> Cadastre.Language.new("nl") |> Cadastre.Language.name(":)")
  "Dutch"

  iex> Cadastre.Language.name("something wrong", "be")
  nil
  ```
  """
  @spec name(t, id) :: String.t()
  def name(language, locale)
  def name(%__MODULE__{name: name}, locale), do: name |> Backend.translate("languages", locale)
  def name(_, _), do: nil

  @doc """
  Returns language native name

  ## Examples
  ```
  iex> Cadastre.Language.new("nl") |> Cadastre.Language.native_name()
  "Nederlands"

  iex> Cadastre.Language.native_name("something wrong")
  nil
  ```
  """
  @spec native_name(t) :: String.t()
  def native_name(%__MODULE__{id: id} = language), do: name(language, id)
  def native_name(_), do: nil
end
