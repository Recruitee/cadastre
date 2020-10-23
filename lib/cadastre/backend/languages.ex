defmodule Cadastre.Backend.Languages do
  @moduledoc false

  alias Cadastre.Language

  languages_path = Application.app_dir(:cadastre, "priv/languages.erl")

  @external_resource languages_path

  languages_data =
    languages_path
    |> File.read!()
    |> :erlang.binary_to_term()

  def languages do
    unquote(
      Enum.map(languages_data, fn {id, name} -> Macro.escape(%Language{id: id, name: name}) end)
    )
  end

  def language_ids, do: unquote(Enum.map(languages_data, fn {id, _} -> id end))

  languages_data
  |> Enum.each(fn {id, name} ->
    language = Macro.escape(%Language{id: id, name: name})

    def language(unquote(id)), do: unquote(language)
    def language(unquote(String.upcase(id))), do: unquote(language)
  end)

  def language(_), do: nil
end
