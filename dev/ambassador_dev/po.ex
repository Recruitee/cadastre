defmodule AmbassadorDev.PO do
  @moduledoc """
  The module is responsible for writing downloaded data to Gettext PO files.
  """

  alias AmbassadorDev.Source

  @gettext_dir "priv/gettext"

  @spec write(
          binary,
          Source.msgid_per_id(),
          Source.msgstr_per_msgid_per_lang(),
          Source.override_per_lang_per_id()
        ) :: :ok
  def write(domain, msgid_per_id, msgstr_per_msgid_per_lang, override_per_lang_per_id) do
    msgid_per_id = msgid_per_id |> Enum.sort_by(fn {id, _} -> id end)

    delete_files(domain)

    langs(msgstr_per_msgid_per_lang, override_per_lang_per_id)
    |> Enum.each(fn
      "en" ->
        :ok

      lang ->
        msgstr_per_msgid = msgstr_per_msgid_per_lang |> Map.get(lang, %{})

        msgid_per_id
        |> Enum.group_by(fn {_, msgid} -> msgid end, fn {id, _} -> id end)
        |> Enum.sort_by(fn {_, [id | _]} -> id end)
        |> Enum.map(fn {msgid, ids} ->
          msgstr = msgstr_per_msgid |> Map.get(msgid, "")
          po_translation(lang, ids, msgid, msgstr, override_per_lang_per_id)
        end)
        |> write_to_file(lang, domain)
    end)
  end

  defp langs(msgstr_per_msgid_per_lang, override_per_lang_per_id) do
    downloaded_langs = msgstr_per_msgid_per_lang |> Map.keys()

    langs_from_overrides =
      override_per_lang_per_id
      |> Enum.flat_map(fn {_id, override_per_lang} -> override_per_lang |> Map.keys() end)

    [downloaded_langs | langs_from_overrides] |> List.flatten() |> Enum.uniq()
  end

  defp po_translation(lang, ids, msgid, msgstr, override_per_lang_per_id) do
    override_per_lang =
      Enum.reduce(ids, %{}, fn id, acc ->
        Map.merge(acc, Map.get(override_per_lang_per_id, id, %{}))
      end)

    {new_msgstr, comments} =
      new_and_comments(override_per_lang, lang, msgstr, "original msgstr", [])

    {new_msgid, comments} =
      new_and_comments(override_per_lang, "en", msgid, "original msgid", comments)

    id_comment = ids |> Enum.sort() |> Enum.map(&~s("#{&1}")) |> Enum.join(", ")

    %Gettext.PO.Translation{
      msgid: [new_msgid],
      msgstr: [new_msgstr],
      comments: ["# #{id_comment}" | comments]
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

  defp delete_files(domain) do
    with {:ok, dirs} <- File.ls(@gettext_dir) do
      dirs |> Enum.each(&File.rm("#{lc_messages_path(&1)}/#{domain}.po"))
    end
  end

  defp write_to_file(translations, lang, domain) do
    lang_dir = lc_messages_path(lang)
    File.mkdir_p(lang_dir)
    io_data = %Gettext.PO{translations: translations} |> Gettext.PO.dump()
    "#{lang_dir}/#{domain}.po" |> File.write!(io_data)
  end

  defp lc_messages_path(lang), do: "#{@gettext_dir}/#{lang}/LC_MESSAGES"
end
