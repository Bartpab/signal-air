defmodule SignalAirWeb.Monitoring.CitoyenLiveTest do
    use SignalAirWeb.LiveViewConnCase

    @fixtures [
      SignalAir.Fixture.Signalement.NuisanceOlfactive.nouveau(signaler_par_id: "user:1"),
      SignalAir.Fixture.Signalement.NuisanceOlfactive.nouveau(signaler_par_id: "user:2")
    ]
    
    setup do
      SignalAirWeb.Endpoint.subscribe("global")
      Enum.each @fixtures, &(SignalAir.Signalement.créer &1)
    end

    test "liste les signalements du citoyen", %{conn: conn} do
        conn = conn
          |> assign(:client_id, "user:1")
          |> get(Routes.live_path(conn, SignalAirWeb.Surveillance.CitoyenLive))
        
        assert html_response(conn, 200)
      
        {:ok, _view, html} = live(conn)

        [mon_signalement]   = SignalAir.Signalement.liste(signaler_par_id: "user:1")
        [autre_signalement] = SignalAir.Signalement.liste(signaler_par_id: "user:2")
        
        # Simulate an event to get the result of the broadcast
        assert html =~ "id=\"signalement_#{mon_signalement.id}\""
        refute html =~ "id=\"signalement_#{autre_signalement.id}\""
      end
end
  