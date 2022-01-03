defmodule SignalAirWeb.PageController do
  use SignalAirWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
