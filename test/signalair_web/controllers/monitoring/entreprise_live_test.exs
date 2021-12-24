defmodule SignalAirWeb.Monitoring.EntrepriseLiveTest do
    use SignalAirWeb.LiveViewConnCase

    alias Phoenix.PubSub
    
    @create_attrs %{long: 0.0, lat: 0.0, type_odeur: "Une odeur", intensite_odeur: 3}
    
    setup do
      SignalAirWeb.Endpoint.subscribe("global")
    end

    test "connected mount", %{conn: conn} do
        conn = get(conn, Routes.live_path(conn, SignalAirWeb.Monitoring.EntrepriseLive))
        assert html_response(conn, 200)
      
        {:ok, view, html} = live(conn)
        SignalAirWeb.Endpoint.broadcast("global", "nouveau_signalement", @create_attrs)
        
        # Simulate an event to get the result of the broadcast
        render_hook(view, :foo) =~ "Une odeur"
      end
end
  