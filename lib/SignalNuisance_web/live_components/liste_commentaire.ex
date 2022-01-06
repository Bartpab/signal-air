defmodule SignalNuisance.LiveComponent.Commentaire.Liste do
    use Phoenix.LiveComponent
    use Phoenix.HTML

    alias SignalNuisance.Commentaire

    def mount(socket) do
      {:ok, socket 
      |> assign(:parent_id, nil)
      |> assign(:afficher_formulaire, false)}
    end   

    def update(assigns, socket) do
        {:ok, socket 
        |> assign(:client, assigns.client)
        |> assign(:parent_id, assigns.parent_id)
        |> assign(:commentaires, SignalNuisance.Commentaire.liste(parent_id: assigns.parent_id))
      }    
    end

    def render(assigns) do
      ~H"""
      <div>
        <a href="#" >Commentaires</a>
        <%= for commentaire <- @commentaires do %>
          <p><%= commentaire.contenu %></p>
        <% end %>
        <hr/>
        <hr/>
        <a href="#" phx-click="afficher_formulaire" phx-target={@myself}>Répondre</a>
        
        <%= if @afficher_formulaire do %>
          <.live_component 
            module={SignalNuisance.Component.Formulaire.Commentaire} 
            id={"formulaire_commentaire_#{@parent_id}"} 
            client={@client}
            myparent={@myself}
            parent_id={@parent_id} />
        <% end %>
      </div>
      """
    end

    def handle_event("afficher_formulaire", _, socket) do
      {:noreply, socket |> assign(:afficher_formulaire, true)}
    end

    def handle_event(:submitted,  %{commentaire: commentaire} = event, socket) do
      {:noreply, 
        socket 
        |> assign(:afficher_formulaire, false)
        |> assign(:commentaires, [socket.assigns.commentaires | commentaire])
      }
    end

  end