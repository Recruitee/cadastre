defmodule Cadastre.Country do
  @moduledoc """
  Country implementation.
  """
  alias Cadastre.Language

  @external_resource Application.app_dir(:cadastre, "priv/data/countries.etf")

  @enforce_keys [:id]
  defstruct [:id]

  @type id :: <<_::16>>
  @type t :: %__MODULE__{id: id}

  external_data = @external_resource |> File.read!() |> :erlang.binary_to_term()
  ids = external_data |> Enum.map(&elem(&1, 0))

  @doc """
  Returns all ids (ISO_3166-1).

  ## Examples

      iex> Cadastre.Country.ids() |> Enum.take(10)
      ["AD", "AE", "AF", "AG", "AI", "AL", "AM", "AO", "AQ", "AR"]

  """
  @spec ids :: [id]
  def ids, do: unquote(ids)

  @doc """
  Returns all countries.

  ## Examples

      iex> Cadastre.Country.all() |> Enum.take(3)
      [
        %Cadastre.Country{id: "AD"},
        %Cadastre.Country{id: "AE"},
        %Cadastre.Country{id: "AF"}
      ]

      iex> Cadastre.Country.all() |> Enum.count()
      249

  """
  @spec all :: [t]
  def all, do: ids() |> Enum.map(&%__MODULE__{id: &1})

  @doc """
  Returns `%Cadastre.Country{}` for valid `id` or `nil` for invalid `id`.

  ## Examples

      iex> Cadastre.Country.new("NL")
      %Cadastre.Country{id: "NL"}

      iex> Cadastre.Country.new("nl")
      %Cadastre.Country{id: "NL"}

      iex> Cadastre.Country.new("xx")
      nil

  """
  @spec new(id | any) :: t | nil
  def new(id) when id in unquote(ids), do: %__MODULE__{id: id}

  def new(str) when is_binary(str) do
    id = str |> String.upcase()

    case id in ids() do
      true -> %__MODULE__{id: id}
      _ -> nil
    end
  end

  def new(_), do: nil

  @doc """
  Returns country name translation for `locale`

  ## Examples

      iex> Cadastre.Country.new("NL") |> Cadastre.Country.name("be")
      "Нідэрланды"

      iex> Cadastre.Country.new("NL") |> Cadastre.Country.name(":)")
      "Netherlands"

      iex> Cadastre.Country.name("something wrong", "be")
      nil

  """
  @spec name(t, Language.id()) :: String.t()
  def name(country, locale)

  external_data
  |> Enum.each(fn {id, translations} ->
    translations = translations |> Map.new()
    en = translations |> Map.fetch!("en")

    def name(%__MODULE__{id: unquote(id)}, locale) do
      unquote(Macro.escape(translations)) |> Map.get(locale, unquote(en))
    end
  end)

  def name(_, _), do: nil
end
