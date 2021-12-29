defmodule SignalAirWeb.Surveillance.CitoyenLive do
    use SignalAirWeb, :live_view

    alias SignalAir.Signalement.NuisanceOlfactive
    alias SignalAir.Signalement
    
    def render(assigns) do
      ~H"""
      <h2><%= gettext "Mes signalements" %></h2>
      <%= for signalement <- @signalements do %>
        <div class="card" {[id: "signalement_#{signalement.id}"]} >
          <div class="card-body">
          <h5 class="card-title"><%= 
            case signalement.type do
              "nuisance_olfactive" -> "Nuisance Olfactive"
              _ -> "Nuisance"
            end
          %></h5>
          <h6 class="card-subtitle mb-2 text-muted"><%= signalement.odeur.intensite %> | <%= signalement.cree_le %></h6>
          <p class="card-text"><%= signalement.odeur.type %></p>
          </div>
        </div>
      <% end %>
      """
    end

    def handle_info(msg, %{assigns: %{signalements: signalements}} = socket) do
      case msg do
        %Phoenix.Socket.Broadcast{
          topic: "global", 
          event: "nouveau_signalement", 
          payload: signalement
        } -> {:noreply, 
            socket 
              |> assign(:signalements, [signalement | signalements])
              |> push_event("nouveau_signalement", signalement)
          }
        _ -> {:noreply, socket}
      end

    end

    def handle_event(event, _params, socket) do
      {:noreply, socket}
    end

    def mount(_params, %{"client_id" => client_id} = session, socket) do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(SignalAir.PubSub, "global")
      end
      {:ok, socket |> assign(:signalements, Signalement.liste(signaler_par: client_id))}
    end

end
  