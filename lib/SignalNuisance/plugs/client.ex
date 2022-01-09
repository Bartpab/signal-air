defmodule SignalNuisance.Client do
  defstruct [id: nil, mode: nil]

  def id(client) do
    if Map.has_key?(client, :as) do
      client.as
    else
      client.id
    end
  end
end

defmodule SignalNuisance.Plugs.Client do
    @behaviour Plug

    import Plug.Conn
    
    @impl true
    def init(default), do: default

    def inject_in_live(conn) do
      %{"client" => conn.assigns.client}
    end

    @impl true
    def call(conn, _config) do
      if conn.assigns[:client] do
        conn
      else
        case get_session(conn, :session_id) do
          nil ->
            conn 
            |> assign(:client, %SignalNuisance.Client{id: :anonyme, mode: :session})
    
          session_id ->
              conn 
              |> assign(:client, %SignalNuisance.Client{id: "session:#{session_id}", mode: :session})
        end
      end
    end
end