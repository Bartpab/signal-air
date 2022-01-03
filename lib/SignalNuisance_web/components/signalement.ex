defmodule SignalNuisance.Component.Signalement do
    use Phoenix.Component
  
    # Optionally also bring the HTML helpers
    # use Phoenix.HTML
  
    def entrée(%{signalement: signalement} = assigns) do
      ~H"""
      <div class="card">
        <div class="card-body">
          <h5 class="card-title">
          <%= case signalement.stype do
              "nuisance_olfactive" -> "Nuisance olfactive"
              _ -> "Nuisance"
            end
            %>
          </h5>
          <h6 class="card-subtitle mb-2 text-muted">Signalé <%= signalement.cree_le |> Timex.from_now  %> | <%= signalement.nb_vues %> Vue(s) </h6>
          <p class="card-text"><%= case signalement.stype do
            "nuisance_olfactive" -> "Intensité: #{signalement.intensite} / 3 | Type: #{signalement.type}"
            _ -> "Nuisance"
          end
          %></p>
        </div>
      </div>
      """
    end
  end