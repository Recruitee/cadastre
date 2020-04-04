defmodule AmbassadorDev.PO do
  @moduledoc """
  The module is responsible for writing downloaded data to Gettext PO files.
  """

  alias AmbassadorDev.Source

  @spec write(
          binary,
          Source.msgid_per_id(),
          Source.msgstr_per_msgid_per_lang(),
          Source.override_per_lang_per_id()
        ) :: :ok
  def write(domain, msgid_per_id, msgstr_per_msgid_per_lang, override_per_lang_per_id) do
    msgid_per_id = msgid_per_id |> Enum.sort_by(fn {id, _} -> id end)

    langs(msgstr_per_msgid_per_lang, override_per_lang_per_id)
    |> Enum.each(fn
      "en" ->
        :ok

      lang ->
        msgstr_per_msgid = msgstr_per_msgid_per_lang |> Map.get(lang, %{})

        msgid_per_id
        |> Enum.map(fn {id, msgid} ->
          msgstr = msgstr_per_msgid |> Map.get(msgid, "")
          po_translation(lang, id, msgid, msgstr, override_per_lang_per_id)
        end)
        |> write(lang, domain)
    end)
  end

  defp langs(msgstr_per_msgid_per_lang, override_per_lang_per_id) do
    downloaded_langs = msgstr_per_msgid_per_lang |> Map.keys()

    langs_from_overrides =
      override_per_lang_per_id
      |> Enum.flat_map(fn {_id, override_per_lang} -> override_per_lang |> Map.keys() end)

    [downloaded_langs | langs_from_overrides] |> List.flatten() |> Enum.uniq()
  end

  defp po_translation(lang, id, msgid, msgstr, override_per_lang_per_id) do
    override_per_lang = override_per_lang_per_id |> Map.get(id, %{})

    {new_msgstr, comments} =
      new_and_comments(override_per_lang, lang, msgstr, "original msgstr", [])

    {new_msgid, comments} =
      new_and_comments(override_per_lang, "en", msgid, "original msgid", comments)

    %Gettext.PO.Translation{
      msgid: [new_msgid],
      msgstr: [new_msgstr],
      comments: ["# #{id}" | comments]
    }
  end

  defp new_and_comments(override_per_lang, lang, old, comment_prefix, comments) do
    override_per_lang
    |> Map.fetch(lang)
    |> case do
      {:ok, ^old} -> {old, comments}
      {:ok, new} -> {new, [~s(# #{comment_prefix}: "#{old}") | comments]}
      _ -> {old, comments}
    end
  end

  defp write(translations, lang, domain) do
    dir_path = "priv/gettext/#{lang}/LC_MESSAGES"
    file_path = "#{dir_path}/#{domain}.po"

    io_data = %Gettext.PO{translations: translations} |> Gettext.PO.dump()

    File.mkdir_p(dir_path)
    File.rm(file_path)
    File.write!(file_path, io_data)
  end
end
