defmodule SignalNuisance.Component.Formulaire.HoraireProduction do
    use Phoenix.LiveComponent
    use SignalNuisance.LiveComponent

    use Phoenix.HTML

    alias SignalNuisance.HoraireProduction

    def mount(socket) do
      {:ok, socket 
        |> assign(changeset: HoraireProduction.changeset())
      }
    end

    def render(assigns) do
      ~H"""
      <div id={@id}>
        <.form let={f} for={@changeset} phx-submit="sauvegarder" phx-target={@myself}>
          <div class="form-group">
            <%= label f, :contenu %>
            <%= textarea f, :contenu, class: "form-control", aria_describedby: "aideCommentaire", placeholder: "Votre commentaire" %>
            
            <small id="aideCommentaire" class="form-text text-muted">Votre commentaire restera anonyme auprès des autres.</small>
          </div>
          <div class="form-group">
            <%= submit "Envoyer", class: "btn btn-primary" %>
          </div>
        </.form>
      </div>
      """
    end
    
    def handle_event("sauvegarder", %{"production" => params}, %{assigns: %{client: client, entreprise: entreprise}} = socket) do
      case params |> Map.put("entreprise_id", entreprise.id) |> HoraireProduction.créer do
        {:ok, production} -> 
          send self(), {:submitted, {HoraireProduction, production}}
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changeset} -> {:noreply, assign(socket, changeset: changeset)}
      end
    end
  end