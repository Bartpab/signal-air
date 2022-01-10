defmodule SignalNuisanceWeb.Surveillance.CitoyenLive do
    use SignalNuisanceWeb, :live_view
    alias SignalNuisance.Signalement
    
    def render(assigns) do
      ~H"""
      <div class="my-3 p-3 bg-body rounded shadow-sm">
        <h1 class="pb-2 mb-0"><%= gettext "Mes signalements" %></h1>
      </div>
      <%= if Enum.empty?(@signalements) do %>
        <div class="d-flex text-muted pt-3">
          Aucun signalement enregistré
        </div>
      <% end %>
      <%= for signalement <- @signalements do %>
        <.live_component 
          module={SignalNuisance.Component.Signalement} 
          id={"signalement_#{signalement.id}"} 
          client={@client} 
          signalement={signalement} />
      <% end %>
      """
    end

    def handle_info(msg, %{assigns: %{signalements: signalements, client: client}} = socket) do
      case msg do
        %{topic: "global", event: "nouveau", payload: {Signalement, signalement}} -> {:noreply, 
            socket 
              |> (&
                if signalement.par_id == client.id do 
                  &1 |> assign(:signalements, [signalement | signalements])
                else &1 end
              ).()
          }
          %Phoenix.Socket.Broadcast {
            topic: "global", 
            event: "cloturé", 
            payload: {Signalement, _signalement_id}
          } -> 
              {:noreply,
                socket 
                |> assign(:signalements, Signalement.liste(ou: [par_id: client.id]))
              }
        %{topic: "global", event: "vu_par", payload: vue} -> {:noreply, socket |> assign(:signalements, Signalement.liste(par_id: client.id))}
        _ -> {:noreply, socket}
      end
    end

    def handle_event(event, _params, socket) do
      {:noreply, socket}
    end

    def mount(_params, %{"client" => client} = _session, socket) do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(SignalNuisance.PubSub, "global")
      end

      {:ok, 
        socket
          |> assign(:client, client) 
          |> assign(:signalements, Signalement.liste(ou: [par_id: client.id]))
      }
    end

end
  