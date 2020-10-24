defmodule Cadastre.Backend.Languages do
  @moduledoc false

  alias Cadastre.Language

  languages_path = Application.app_dir(:cadastre, "priv/languages.erl")

  @external_resource languages_path

  name_per_id = languages_path |> File.read!() |> :erlang.binary_to_term()

  language_per_id =
    name_per_id
    |> Enum.map(fn {id, name} -> {id, Macro.escape(%Language{id: id, name: name})} end)

  languages = language_per_id |> Enum.map(fn {_, language} -> language end)
  ids = language_per_id |> Enum.map(fn {id, _} -> id end)

  def languages, do: unquote(languages)
  def language_ids, do: unquote(ids)

  language_per_id
  |> Enum.each(fn {id, language} ->
    def language(unquote(id)), do: unquote(language)
  end)

  ids
  |> Enum.each(fn id ->
    upcased_id = id |> String.upcase()
    def language(unquote(upcased_id)), do: language(unquote(id))
  end)

  def language(_), do: nil
end
