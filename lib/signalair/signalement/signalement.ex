defmodule SignalAir.Signalement do
    alias SignalAir.Signalement.NuisanceOlfactive
    import Ecto.Query, warn: false
    alias SignalAir.Repo

    def create_nuisance_olfactive(attrs \\ %{}) do
        %NuisanceOlfactive{}
        |> NuisanceOlfactive.changeset(attrs)
        |> Repo.insert()
    end

    def liste_nuisance_olfactive() do
        Repo.all(NuisanceOlfactive)
    end
end