defmodule SignalNuisance.Signalement do
    alias SignalNuisance.VueSignalement

    @repo Application.get_env(:SignalNuisance, :repo)

    def créer(%Ecto.Changeset{valid?: false} = changeset) do
        {:error, changeset}
    end

    def créer(%Ecto.Changeset{valid?: true} = changeset) do
        changeset |> Ecto.Changeset.apply_changes |> créer
    end

    def créer(%SignalNuisance.Signalement.NuisanceOlfactive{} = signalement) do
        with {:ok, signalement} <- signalement |> Map.put(:cree_le, Timex.now()) |> @repo.créer(as: __MODULE__) do
            notifier(:nouveau_signalement, signalement)
        end
    end

    defp notifier(:nouveau_signalement, signalement) do
        SignalNuisanceWeb.Endpoint.broadcast("global", "nouveau_signalement", signalement) 
        {:ok, signalement}
    end

    defp notifier(:nouvelle_vue, vue) do
        SignalNuisanceWeb.Endpoint.broadcast("global", "vu_par", vue) 
        :ok
    end

    def ajouter_vu_par(signalement_id, client_id) do
        vue = %VueSignalement{signalement_id: signalement_id, vu_par_id: client_id}
        with [] <- @repo.liste(VueSignalement, where: fn(x) -> x.signalement_id == signalement_id and x.vu_par_id == client_id end),
            {:ok, vue} <- @repo.créer(vue),
            {:ok, signalement} <- récupérer(signalement_id),
            :ok <- modifier(signalement.id, nb_vues: signalement.nb_vues + 1)
        do
            notifier(:nouvelle_vue, vue)
        end
    end

    def modifier(id, modifications) do
        __MODULE__ |> @repo.modifier(id, modifications)
    end

    def récupérer(id) do
        __MODULE__ |> @repo.récupérer(id)
    end

    def liste(opts \\ []) do
        opts = opts 
        |> Enum.map(fn ({k, v}) -> {:where, fn (x) -> Map.get(x, k) == v end} end)
        __MODULE__ |> @repo.liste(opts)
    end
end