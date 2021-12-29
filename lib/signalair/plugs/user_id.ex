defmodule SignalAir.Plugs.ClientId do
    @behaviour Plug

    import Plug.Conn
  
    @impl true
    def init(default), do: default

    def inject_in_live(conn) do
      %{"client_id" => conn.assigns.client_id}
    end

    @impl true
    def call(conn, _config) do
      if conn.assigns[:client_id] do
        conn
      else
        case get_session(conn, :session_id) do
          nil ->
            conn 
              |> assign(:client_id, :anonyme)
              |> assign(:client_mode, :anonyme)
    
          session_id ->
              conn 
                  |> assign(:client_id, "session:#{session_id}")
                  |> assign(:client_mode, :session)
        end
      end
    end
end