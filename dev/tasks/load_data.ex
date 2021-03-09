defmodule Mix.Tasks.LoadData do
  @moduledoc false

  use Mix.Task

  @shortdoc "Loads data for languages, countries and subdivisions"

  @impl Mix.Task
  def run(_) do
    CadastreDev.Loader.load_data()
  end
end
