defmodule SignalNuisance.Signalement do
    alias SignalNuisance.VueSignalement

    @repo Application.get_env(:SignalNuisance, :repo)

    def ajouter_vu_par(signalement_id, client_id) do
        vue = %VueSignalement{signalement_id: signalement_id, vu_par_id: client_id}
        with [] <- @repo.liste(VueSignalement, where: fn(x) -> x.signalement_id == signalement_id and x.vu_par_id == client_id end),
            {:ok, vue} <- @repo.créer(vue),
            {:ok, signalement} <- récupérer(signalement_id),
            :ok <- modifier(signalement.id, nb_vues: signalement.nb_vues + 1)
        do
            SignalNuisanceWeb.Endpoint.broadcast("global", "vu_par", [vue.signalement_id, vue.vu_par_id]) 
        end
    end

    def cloturer(signalement_or_id) do
        signalement_id = case signalement_or_id do
            %_type{id: signalement_id} -> signalement_id
            _ -> signalement_or_id
        end

        __MODULE__ |> @repo.modifier(signalement_id, cloture: true, cloture_le: Timex.now(), modifie_le: Timex.now())
        SignalNuisanceWeb.Endpoint.broadcast("global", "cloturé", {__MODULE__, signalement_id}) 
        SignalNuisanceWeb.Endpoint.broadcast("global", "signalement_cloturé", signalement_id) 
    end

    use SignalNuisance.Model, polymorphism: true
end