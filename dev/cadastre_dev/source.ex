defmodule CadastreDev.Source do
  @moduledoc false

  alias CadastreDev.API
  alias CadastreDev.CSV

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
  @callback override_per_lang_per_id() :: override_per_lang_per_id

  @langs "priv/dev/languages.csv" |> CSV.load() |> Enum.map(&List.first(&1)) |> Enum.sort()
  @download_timeout 60_000

  @spec langs() :: [lang]
  def langs, do: @langs

  @spec override_per_lang_per_id_from_csv(binary) :: override_per_lang_per_id
  def override_per_lang_per_id_from_csv(filename) do
    "priv/dev/overrides/#{filename}.csv"
    |> CSV.load()
    |> Enum.reduce(%{}, fn [id, lang, msgstr], acc ->
      acc |> Map.update(id, %{lang => msgstr}, &Map.put(&1, lang, msgstr))
    end)
  end

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
