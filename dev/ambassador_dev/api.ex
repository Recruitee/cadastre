defmodule AmbassadorDev.API do
  @moduledoc """
  API for downloading ISO data
  """

  @endpoint "https://salsa.debian.org/api/v4/projects/2957"

  def download_po(path) do
    path
    |> download_file()
    |> Gettext.PO.parse_string!()
    |> Map.fetch!(:translations)
    |> Enum.flat_map(fn
      %{msgstr: [""]} -> []
      %{msgid: [msgid], msgstr: [msgstr]} -> [{msgid, msgstr}]
      _ -> []
    end)
    |> Enum.into(%{})
  end

  def download_json(path) do
    path |> download_file() |> Jason.decode!()
  end

  def file_names(dir_path) do
    dir_path
    |> call_file_names()
    |> List.flatten()
    |> Enum.filter(fn
      %{"type" => "blob", "name" => _} -> true
      _ -> false
    end)
    |> Enum.map(fn %{"name" => name} -> name end)
  end

  defp call_file_names(dir_path, page \\ 1) do
    case call_api("repository/tree", path: dir_path, per_page: 100, page: page) do
      [] -> []
      list -> [list | call_file_names(dir_path, page + 1)]
    end
  end

  defp download_file(path) do
    case call_api("repository/files/#{URI.encode_www_form(path)}", ref: "master") do
      %{"content" => base64} -> Base.decode64!(base64)
      response -> raise "Can't download #{path}. Response:\n#{inspect(response)}"
    end
  end

  defp call_api(path, query) do
    url = path |> api_url(query)

    url
    |> String.to_charlist()
    |> :httpc.request()
    |> case do
      {:ok, {{_, 200, _}, _, body}} -> Jason.decode!(body)
      {:ok, {{_, status, _}, _, _}} -> raise "GET #{url} responded with #{status}"
    end
  end

  defp api_url(path, query) do
    "#{@endpoint}/#{path}/?#{URI.encode_query(query)}"
  end
end
