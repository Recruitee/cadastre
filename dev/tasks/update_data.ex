defmodule Mix.Tasks.UpdateData do
  @moduledoc false

  use Mix.Task

  @shortdoc "Updates data for languages, countries and subdivisions"

  @impl Mix.Task
  def run(_) do
    CadastreDev.update_data()
  end
end
