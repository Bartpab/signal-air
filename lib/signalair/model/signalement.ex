defmodule SignalAir.Signalement do
    alias SignalAir.VueSignalement

    @repo Application.get_env(:SignalAir, :repo)

    def créer(%Ecto.Changeset{valid?: false} = changeset) do
        {:error, changeset}
    end

    def créer(%Ecto.Changeset{valid?: true} = changeset) do
        changeset |> Ecto.Changeset.apply_changes |> créer
    end

    def créer(%SignalAir.Signalement.NuisanceOlfactive{} = signalement) do
        with {:ok, signalement} <- signalement |> @repo.créer(as: __MODULE__) do
            notifier(:nouveau_signalement, signalement)
        end
    end

    defp notifier(:nouveau_signalement, signalement) do
        SignalAirWeb.Endpoint.broadcast("global", "nouveau_signalement", signalement) 
        {:ok, signalement}
    end

    defp notifier(:nouvelle_vue, vue) do
        SignalAirWeb.Endpoint.broadcast("global", "vu_par", vue) 
        :ok
    end

    def ajouter_vu_par(signalement_id, client_id) do
        vue = %VueSignalement{signalement_id: signalement_id, vu_par_id: client_id}
        with false <- @repo.existe?(vue),
            {:ok, vue} <- @repo.créer(vue) 
        do
            notifier(:nouvelle_vue, vue)
        end
    end

    def recuperer(id) do
        __MODULE__ |> @repo.récupérer(id)
    end

    def liste(opts \\ []) do
        opts = opts 
        |> Enum.map(fn ({k, v}) -> {:where, fn (x) -> Map.get(x, k) == v end} end)
        __MODULE__ |> @repo.liste(opts)
    end
end