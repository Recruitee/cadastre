defmodule CadastreDev.CSV do
  @moduledoc false

  @spec load(Path.t()) :: Enumerable.t()
  def load(path) do
    path
    |> File.stream!([:read, :utf8])
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: true)
  end
end
