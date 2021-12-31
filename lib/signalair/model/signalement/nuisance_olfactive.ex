defmodule SignalAir.Signalement.NuisanceOlfactive do
    alias SignalAir.Signalement.NuisanceOlfactive
    alias SignalAir.Signalement

    def __changeset__, do: Signalement.Commun.inherits_changeset type: :string,  intensite: :integer
    
    @derive Jason.Encoder
    defstruct Signalement.Commun.inherits_struct("nuisance_olfactive", type: nil, intensite: nil)

    def changeset(attrs \\ %{}) do
        %NuisanceOlfactive{} 
            |> Ecto.Changeset.cast(attrs, Map.keys(__changeset__())) 
            |> Ecto.Changeset.validate_required(Map.keys(__changeset__()))
    end

    def validate(attrs)  do
        __MODULE__.changeset(attrs)
    end
end