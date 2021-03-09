defmodule CadastreDev.Source do
  @moduledoc false

  alias CadastreDev.API

  @type lang :: <<_::16>>
  @type id :: binary
  @type msgid :: binary
  @type msgstr :: binary
  @type msgid_per_id :: %{optional(id) => msgid}
  @type msgstr_per_msgid :: %{optional(msgid) => msgstr}
  @type msgstr_per_msgid_per_lang :: %{optional(lang) => msgstr_per_msgid}
  @type override_per_lang_per_id :: %{optional(id) => %{optional(lang) => msgstr}}

  @callback msgid_per_id() :: msgid_per_id
  @callback msgstr_per_msgid_per_lang() :: msgstr_per_msgid_per_lang

  @langs "priv/dev/allowed_languages.json" |> File.read!() |> Jason.decode!() |> Map.keys()
  @download_timeout 60_000

  @spec langs() :: [lang]
  def langs, do: @langs

  @spec load_msgstr_per_msgid_per_lang(binary) :: msgstr_per_msgid_per_lang
  def load_msgstr_per_msgid_per_lang(path) do
    path
    |> API.file_names()
    |> Enum.reduce([{"zh", "zh_CN.po"}], fn
      <<lang::binary-size(2), ".po">> = filename, acc when lang in @langs ->
        [{lang, filename} | acc]

      _, acc ->
        acc
    end)
    |> Task.async_stream(
      fn {lang, filename} ->
        {lang, API.download_po("#{path}/#{filename}")}
      end,
      ordered: false,
      timeout: @download_timeout
    )
    |> Enum.map(fn {:ok, {lang, msgstr_per_msgid}} -> {lang, msgstr_per_msgid} end)
    |> Enum.into(%{})
  end
end
