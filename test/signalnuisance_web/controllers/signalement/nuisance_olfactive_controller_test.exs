defmodule SignalNuisanceWeb.Signalement.NuisanceOlfactiveControllerTest do
    use SignalNuisanceWeb.ConnCase
    
    @create_attrs %{long: 0.0, lat: 0.0, type: "Une odeur", intensite: 3}
    @expected_attrs %{
      long: 0.0, 
      lat: 0.0, 
      stype: "nuisance_olfactive",
      type: "Une odeur", 
      intensite: 3, 
      signaler_par_id: "user:123"
    }
    
    setup do
      SignalNuisanceWeb.Endpoint.subscribe("global")
    end

    test "créer nouvelle nuisance olfactive", %{conn: conn} do
      conn = conn 
        |> assign(:client_id, "user:123")
        |> post(Routes.nuisance_olfactive_path(conn, :create), nuisance_olfactive: @create_attrs)
      
      assert redirected_to(conn) == Routes.live_path(conn, SignalNuisanceWeb.Surveillance.CitoyenLive)
      assert_receive %Phoenix.Socket.Broadcast{topic: "global", event: "nouveau_signalement",  payload: @expected_attrs}
    end
end
  