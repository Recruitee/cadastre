defmodule Ambassador.Language do
  @moduledoc """
  Language implementation
  """
  alias Ambassador.Backend

  @enforce_keys [:id, :name]
  defstruct [:id, :name]

  @type id :: <<_::16>>
  @type t :: %__MODULE__{id: id, name: Ambassador.msgid()}

  @doc """
  Returns all languages

  ## Examples

  iex> Ambassador.Language.all() |> Enum.take(3)
  [
    %Ambassador.Language{id: "aa", name: "Afar"},
    %Ambassador.Language{id: "ab", name: "Abkhazian"},
    %Ambassador.Language{id: "af", name: "Afrikaans"}
  ]

  iex> Ambassador.Language.all() |> Enum.count()
  140
  """
  @spec all :: [t]
  def all, do: Backend.languages()

  @doc """
  Return all ids (ISO_639-2)

  ## Examples

  iex> Ambassador.Language.ids() |> Enum.take(10)
  ["aa", "ab", "af", "am", "an", "as", "av", "ba", "be", "bg"]
  """
  @spec ids :: [id]
  def ids, do: Backend.language_ids()

  @doc """
  Returns %Ambassador.Language{} for valid `id`.
  Returns `nil` for invalid `id`.

  ## Examples

  iex> Ambassador.Language.new("nl")
  %Ambassador.Language{id: "nl", name: "Dutch"}

  iex> Ambassador.Language.new("NL")
  %Ambassador.Language{id: "nl", name: "Dutch"}

  iex> Ambassador.Language.new("xx")
  nil
  """
  @spec new(id | any) :: t | nil
  def new(id), do: Backend.language(id)

  @doc """
  Returns language name translation for `locale`

  ## Examples

  iex> Ambassador.Language.new("nl") |> Ambassador.Language.name("be")
  "галандская"

  iex> Ambassador.Language.new("nl") |> Ambassador.Language.name(":)")
  "Dutch"

  iex> Ambassador.Language.name("something wrong", "be")
  nil
  """
  @spec name(t, id) :: String.t()
  def name(%__MODULE__{name: name}, locale), do: name |> Backend.translate("languages", locale)
  def name(_, _), do: nil

  @doc """
  Returns language native name

  ## Examples

  iex> Ambassador.Language.new("nl") |> Ambassador.Language.native_name()
  "Nederlands"

  iex> Ambassador.Language.native_name("something wrong")
  nil
  """
  @spec native_name(t) :: String.t()
  def native_name(%__MODULE__{id: id} = language), do: name(language, id)
  def native_name(_), do: nil
end
