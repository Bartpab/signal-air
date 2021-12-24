defmodule SignalAirWeb.PageControllerTest do
  use SignalAirWeb.ConnCase

  test "GET /", %{conn: conn} do
    _conn = get(conn, "/")
    assert true
  end
end
