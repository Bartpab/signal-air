defmodule SignalNuisanceWeb.PageControllerTest do
  use SignalNuisanceWeb.ConnCase

  test "GET /", %{conn: conn} do
    _conn = get(conn, "/")
    assert true
  end
end
