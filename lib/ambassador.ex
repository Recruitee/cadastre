defmodule Ambassador do
  @moduledoc """
  A repository of languages, countries and country subdivisions
  """

  @type msgid :: String.t()
  @type msgstr :: String.t()
  @type locale :: <<_::16>>
end
