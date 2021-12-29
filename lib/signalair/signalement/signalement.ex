defmodule SignalAir.Signalement do
    alias SignalAir.Signalement.NuisanceOlfactive
    alias SignalAir.Signalement

    import Ecto.Query, warn: false
    alias SignalAir.Repo
    
    use Ecto.Schema
    import Ecto.Changeset
  
    @derive {Jason.Encoder, only: [:lat, :long, :type, :signaler_par_id, :cree_le]}
    schema "signalement" do
      field :lat, :float
      field :long, :float
      field :type, :string
      field :signaler_par_id, :string
      has_one :odeur, SignalAir.Signalement.NuisanceOlfactive
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

    def creer_nuisance_olfactive(attrs \\ %{}) do
        with {:ok, signalement} <- attrs |> Map.put("type", "nuisance_olfactive") |> creer,
            {:ok, _} <- %NuisanceOlfactive{signalement_id: signalement.id} 
                |> NuisanceOlfactive.changeset(
                    attrs 
                        |> Map.delete("lat")
                        |> Map.delete("long")
                        |> Map.delete("signaler_par_id")
                ) |> Repo.insert,
        do: recuperer(signalement.id)
    end

    defp preload_specs(req) do
        req |> Repo.preload(:odeur)
    end

    def recuperer(id) do
        case Signalement |> Repo.get(id) |> preload_specs do
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
        |> preload_specs
    end
end