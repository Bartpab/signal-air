defmodule SignalAir.Signalement do
    alias SignalAir.Signalement.NuisanceOlfactive
    alias SignalAir.Signalement.Vue
    alias SignalAir.Signalement

    import Ecto.Query, warn: false
    alias SignalAir.Repo
    
    use Ecto.Schema
    import Ecto.Changeset
  
    @derive {Jason.Encoder, only: [:lat, :long, :type, :signaler_par_id, :cree_le]}
    schema "signalements" do
      field :lat, :float
      field :long, :float
      field :type, :string
      field :signaler_par_id, :string
      has_one :odeur, SignalAir.Signalement.NuisanceOlfactive
      has_many :vues, SignalAir.Signalement.Vue
      timestamps(inserted_at: :cree_le)
    end
  
    @doc false
    def changeset(signalement, attrs) do
        signalement
      |> cast(attrs, [:type, :lat, :long, :signaler_par_id])
      |> validate_required([:type, :lat, :long, :signaler_par_id])
    end

    defp creer(attrs) do
        %Signalement{}
        |> Signalement.changeset(attrs)
        |> Repo.insert
    end

    defp notifie_nouveau_signalement(signalement) do
        SignalAirWeb.Endpoint.broadcast("global", "nouveau_signalement", signalement) 
        {:ok, signalement}
    end

    defp notifie_nouvelle_vue(signalement) do
        SignalAirWeb.Endpoint.broadcast("global", "vu_par", vue) 
        {:ok, signalement}
    end

    def creer_nuisance_olfactive(attrs \\ %{}) do
        with {:ok, signalement} <- attrs |> Map.put("type", "nuisance_olfactive") |> creer,
            {:ok, _} <- %NuisanceOlfactive{signalement_id: signalement.id} 
                |> NuisanceOlfactive.changeset(
                    attrs 
                        |> Map.delete("lat")
                        |> Map.delete("long")
                        |> Map.delete("signaler_par_id")
                ) |> Repo.insert,
            {:ok, signalement} <- recuperer(signalement.id)
        do
            signalement |> notifie_nouveau_signalement
        end
    end

    def ajouter_vu_par(signalement_id, client_id) do
        unless [] = Vue |> where([vue], vue.signalement_id == ^signalement_id and vue.vu_par_id == ^client_id) |> Repo.all do
            with :ok <- %Vue{signalement_id: signalement_id, vu_par_id: client_id}
                |> Repo.insert
                |> elem(1)
            do

            end
        else
            :ok
        end
    end

    defp précharger_associations(req) do
        req 
            |> Repo.preload(:odeur) 
            |> Repo.preload(:vues)
    end

    def recuperer(id) do
        case Signalement |> Repo.get(id) |> précharger_associations do
            nil -> {:error, "Aucun résultat trouvé."}
            signalement -> {:ok, signalement}
        end
    end

    def liste(opts \\ []) do
        Signalement
        |> (&case opts do
            [{:signaler_par, client_id} | _] when is_nil(client_id) != true -> &1 |> where([y], y.signaler_par_id == ^client_id)
            _ -> &1
        end).()
        |> Repo.all
        |> précharger_associations
    end
end