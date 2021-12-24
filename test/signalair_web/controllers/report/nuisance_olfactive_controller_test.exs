defmodule SignalAirWeb.Report.NuisanceOlfactiveControllerTest do
    use SignalAirWeb.ConnCase

    alias Phoenix.PubSub
    
    @create_attrs %{long: 0.0, lat: 0.0, type_odeur: "Une odeur", intensite_odeur: 3}
    
    setup do
      SignalAirWeb.Endpoint.subscribe("global")
    end

    test "create new nuisance olfactive", %{conn: conn} do
      conn = post(conn, Routes.nuisance_olfactive_path(conn, :create), nuisance_olfactive: @create_attrs)
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert_receive %Phoenix.Socket.Broadcast{topic: "global", event: "nouveau_signalement",  payload: @create_attrs}
    end
end
  