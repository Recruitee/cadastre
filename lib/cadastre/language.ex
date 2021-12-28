defmodule Cadastre.Language do
  @moduledoc """
  Language implementation.
  """
  @external_resource Application.app_dir(:cadastre, "priv/data/languages.etf")

  @enforce_keys [:id]
  defstruct [:id]

  @type id :: <<_::16>>
  @type t :: %__MODULE__{id: id}

  external_data = @external_resource |> File.read!() |> :erlang.binary_to_term()
  ids = external_data |> Enum.map(&elem(&1, 0))

  @doc """
  Returns all ids (ISO_639-2).

  ## Examples

      iex> Cadastre.Language.ids() |> Enum.take(10)
      ["aa", "ab", "ae", "af", "ak", "am", "an", "ar", "as", "av"]

  """
  @spec ids :: [id]
  def ids, do: unquote(ids)

  @doc """
  Returns all languages.

  ## Examples

      iex> Cadastre.Language.all() |> Enum.take(3)
      [
        %Cadastre.Language{id: "aa"},
        %Cadastre.Language{id: "ab"},
        %Cadastre.Language{id: "ae"}
      ]

      iex> Cadastre.Language.all() |> Enum.count()
      178

  """
  @spec all :: [t]
  def all, do: ids() |> Enum.map(&%__MODULE__{id: &1})

  @doc """
  Returns `%Cadastre.Language{}` for valid `id` or `nil` for invalid `id`.

  ## Examples

      iex> Cadastre.Language.new("nl")
      %Cadastre.Language{id: "nl"}

      iex> Cadastre.Language.new("NL")
      %Cadastre.Language{id: "nl"}

      iex> Cadastre.Language.new("xx")
      nil

  """
  @spec new(id | any) :: t | nil
  def new(id) when id in unquote(ids), do: %__MODULE__{id: id}

  def new(str) when is_binary(str) do
    id = str |> String.downcase()

    case id in ids() do
      true -> %__MODULE__{id: id}
      _ -> nil
    end
  end

  def new(_), do: nil

  @doc """
  Returns language name translation for `locale`.

  ## Examples

      iex> Cadastre.Language.new("nl") |> Cadastre.Language.name("be")
      "галандская"

      iex> Cadastre.Language.new("nl") |> Cadastre.Language.name(":)")
      "Dutch"

      iex> Cadastre.Language.name("something wrong", "be")
      nil

  """
  @spec name(t, id) :: String.t()
  def name(language, locale)

  external_data
  |> Enum.each(fn {id, translations} ->
    translations = translations |> Map.new()
    en = translations |> Map.fetch!("en")

    def name(%__MODULE__{id: unquote(id)}, locale) do
      unquote(Macro.escape(translations)) |> Map.get(locale, unquote(en))
    end
  end)

  def name(_, _), do: nil

  @doc """
  Returns language native name.

  ## Examples

      iex> Cadastre.Language.new("nl") |> Cadastre.Language.native_name()
      "Nederlands"

      iex> Cadastre.Language.native_name("something wrong")
      nil

  """
  @spec native_name(t) :: String.t()
  def native_name(%__MODULE__{id: id} = language), do: name(language, id)
  def native_name(_), do: nil
end
