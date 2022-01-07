defmodule SignalNuisance.Component.Formulaire.Commentaire do
    use Phoenix.LiveComponent
    use SignalNuisance.LiveComponent

    use Phoenix.HTML

    alias SignalNuisance.Commentaire

    def mount(socket) do
      {:ok, socket 
        |> assign(changeset: Commentaire.changeset())
      }
    end

    def render(assigns) do
      ~H"""
      <div id={@id}>
        <.form let={f} for={@changeset} phx-submit="sauvegarder" phx-target={@myself}>
          <div class="form-group">
            <%= label f, :contenu %>
            <%= textarea f, :contenu, class: "form-control", aria_describedby: "aideCommentaire", placeholder: "Votre commentaire" %>
            
            <small id="aideCommentaire" class="form-text text-muted">Votre commentaire restera anonyme auprès des autres acteurs.</small>
          </div>
          <div class="form-group">
            <%= submit "Envoyer", class: "btn btn-primary" %>
          </div>
        </.form>
      </div>
      """
    end
    
    def handle_event("sauvegarder", %{"commentaire" => commentaire_params}, %{assigns: %{client: client, parent_id: parent_id}} = socket) do
      case commentaire_params |> Map.put("parent_id", parent_id) |> Map.put("par_id", client.id) |> SignalNuisance.Commentaire.créer do
        {:ok, commentaire} -> 
          send self(), {:submitted, commentaire}
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changeset} -> {:noreply, assign(socket, changeset: changeset)}
      end
    end
  end