defmodule Cadastre.I18n do
  @moduledoc """
  Backend for gettext
  """
  use Gettext, otp_app: :cadastre, one_module_per_locale: true
end
