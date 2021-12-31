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
            case signalement.stype do
              "nuisance_olfactive" -> "Nuisance Olfactive"
              _ -> "Nuisance"
            end
          %></h5>
          <h6 class="card-subtitle mb-2 text-muted"><%= signalement.intensite %> | <%= signalement.cree_le %></h6>
          <p class="card-text"><%= signalement.type %></p>
          </div>
        </div>
      <% end %>
      """
    end

    def handle_info(msg, %{assigns: %{signalements: signalements, client_id: client_id}} = socket) do
      case msg do
        %{topic: "global", event: "nouveau_signalement", payload: signalement} -> {:noreply, 
            socket 
              |> (&
                if signalement.signaler_par_id == client_id do 
                  &1 |> assign(:signalements, [signalement | signalements])
                else &1 end
              ).()
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

      {:ok, 
        socket
          |> assign(:client_id, client_id) 
          |> assign(:signalements, Signalement.liste(signaler_par_id: client_id))
      }
    end

end
  