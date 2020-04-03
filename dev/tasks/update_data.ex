defmodule Mix.Tasks.UpdateData do
  use Mix.Task

  @shortdoc "Updates data for languages, countries and subdivisions"
  @moduledoc """
  Updates data for languages, countries and subdivisions.

  Saves the data to:
  - priv/languages.json,
  - priv/countries.json,
  - priv/subdivisions.json.

  Saves translations to priv/gettext.

  The task isn't compiled to the library so it is not available in your application.
  """

  @impl Mix.Task
  def run(_) do
    AmbassadorDev.update_data()
  end
end
