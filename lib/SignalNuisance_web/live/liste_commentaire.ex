defmodule SignalNuisance.Commentaire.ListeLive do
    use Phoenix.HTML
    use Phoenix.LiveView

    alias SignalNuisance.Commentaire

    def mount(_params, %{"parent_id" => parent_id, "client" => client} = session, socket) do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(SignalNuisance.PubSub, "global")
      end

      {:ok, socket 
        |> assign(:parent_id, parent_id)
        |> assign(:client, client)
        |> assign(:afficher_formulaire, false)
        |> assign(:afficher_commentaires, false)
        |> assign(:commentaires, Commentaire.liste(ou: [parent_id: parent_id]))
        |> assign(:nouveau_commentaires, [])
      }
    end   

    def handle_info(msg, %{assigns: %{commentaires: commentaires, nouveau_commentaires: nouveau_commentaires, client: client, parent_id: parent_id}} = socket) do
      case msg do
        %Phoenix.Socket.Broadcast{topic: _topic, event: "nouveau", payload: {Commentaire, commentaire} = payload} ->
        if commentaire.par_id != SignalNuisance.Client.id(client) and commentaire.parent_id ==  parent_id do
          {:noreply, socket |> assign(:nouveau_commentaires, [commentaire | nouveau_commentaires])}
        else
          {:noreply, socket}
        end
        {:submitted, commentaire} -> 
          {:noreply, 
          socket 
          |> assign(:afficher_formulaire, false)
          |> assign(:afficher_commentaires, true)
          |> assign(:commentaires, [commentaire | commentaires])
        }
        _ -> {:noreply, socket}
      end
    end

    def handle_event("afficher_nouveaux_commentaires", _, %{assigns: %{commentaires: commentaires, nouveau_commentaires: nouveau_commentaires}} = socket) do
      {:noreply, 
        socket 
        |> assign(:commentaires, nouveau_commentaires ++ commentaires )
        |> assign(:nouveau_commentaires, [])
      }
    end

    def handle_event("afficher_formulaire", _, socket) do
      {:noreply, socket |> assign(:afficher_formulaire, true) |> assign(:afficher_commentaires, true)}
    end

    def handle_event("basculer_affichage_commentaires", _, %{assigns: %{afficher_commentaires: afficher_commentaires}} = socket) do
      {:noreply, socket |> assign(:afficher_commentaires, !afficher_commentaires)}
    end

    def render(assigns) do
      ~H"""
      <div>
        <h6>
        <a phx-click="basculer_affichage_commentaires">
          <%= if !@afficher_commentaires do %><i class="bi bi-caret-right"></i><%= else %><i class="bi bi-caret-down"></i><% end %> 
          Commentaires (<%= length(@commentaires) %><%= if length(@nouveau_commentaires) > 0, do: " + #{length(@nouveau_commentaires)}" %>)
        </a>
        </h6>
        <%= if @afficher_commentaires do %>
          <%= if length(@nouveau_commentaires) > 0 do %>
            <a href="#" phx-click="afficher_nouveaux_commentaires"><%= length(@nouveau_commentaires) %> nouveau(x) commentaire(s)</a>
          <% end %>
          <%= if length(@commentaires) > 0 do %>
            <%= for commentaire <- @commentaires do %>
              <div class="d-flex text-muted pt-3">
                <svg class="bd-placeholder-img flex-shrink-0 me-2 rounded" width="32" height="32" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Placeholder: 32x32" preserveAspectRatio="xMidYMid slice" focusable="false"><title>Placeholder</title><rect width="100%" height="100%" fill="#007bff"></rect><text x="50%" y="50%" fill="#007bff" dy=".3em">32x32</text></svg>
          
                <p class="pb-3 mb-0 small lh-sm border-bottom">
                  <strong class="d-block text-gray-dark">@<%= if commentaire.par_id == @client.id, do: "moi", else: "autre"%>, le <%= commentaire.crée_le |> Timex.from_now %></strong>
                  <%= commentaire.contenu %>
                </p>
              </div>
            <% end %>
          <%= else %>
          <div class="d-flex text-muted pt-3">
            <p class="pb-3 mb-0 small lh-sm border-bottom">
              Aucun commentaire...
            </p>
          </div>
          <% end %>
        <% end %>
        <a  phx-click="afficher_formulaire"><i class="bi bi-reply"></i> Répondre</a>
        <%= if @afficher_formulaire do %>
          <.live_component 
            module={SignalNuisance.Component.Formulaire.Commentaire} 
            id={"formulaire_commentaire_#{@parent_id}"} 
            client={@client}
            parent_id={@parent_id} />
        <% end %>
      </div>
      """
    end


  end