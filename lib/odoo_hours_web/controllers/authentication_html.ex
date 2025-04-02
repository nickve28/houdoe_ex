defmodule OdooHoursWeb.AuthenticationHTML do
  @moduledoc """
  This module contains pages rendered by AuthenticationController.

  See the `authentication_html` directory for all templates available.
  """
  use OdooHoursWeb, :html

  embed_templates "authentication_html/*"
end
