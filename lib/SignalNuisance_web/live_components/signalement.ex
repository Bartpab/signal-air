defmodule SignalNuisance.Component.Signalement do
    use Phoenix.LiveComponent

    def mount(socket) do
      {:ok, socket |> assign(:global_id, nil)}
    end   

    def update(assigns, socket) do
      global_id = SignalNuisance.Model.global_id(SignalNuisance.Signalement, assigns.signalement.id)
      {:ok, socket 
      |> assign(:signalement, assigns.signalement)
      |> assign(:client, assigns.client)
      |> assign(:global_id, global_id)
    }    
    end

    def render(assigns) do
      ~H"""
      <div class="card">
        <div class="card-body">
          <h5 class="card-title">
          <%= case @signalement.stype do
              "nuisance_olfactive" -> "Nuisance olfactive"
              _ -> "Nuisance"
            end
            %>
          </h5>
          <h6 class="card-subtitle mb-2 text-muted">Signalé <%= @signalement.cree_le |> Timex.from_now  %> | <%= @signalement.nb_vues %> Vue(s) </h6>
          <p class="card-text"><%= case @signalement.stype do
            "nuisance_olfactive" -> "Intensité: #{@signalement.intensite} / 3 | Type: #{@signalement.type}"
            _ -> "Nuisance"
          end
          %></p>
          <.live_component module={SignalNuisance.LiveComponent.Commentaire.Liste} 
              id={"commentaires_#{@global_id}"} 
              client={@client} 
              parent_id={@global_id} />
        </div>
      </div>
      """
    end   
  end