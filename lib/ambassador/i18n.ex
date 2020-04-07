defmodule Ambassador.I18n do
  @moduledoc """
  Backend for gettext
  """
  use Gettext, otp_app: :ambassador, one_module_per_locale: true
end
