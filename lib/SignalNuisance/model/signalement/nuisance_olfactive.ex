defmodule SignalNuisance.Signalement.NuisanceOlfactive do
    alias SignalNuisance.Signalement.NuisanceOlfactive
    alias SignalNuisance.Signalement

    def __changeset__, do: Signalement.Commun.inherits_changeset type: :string,  intensite: :integer
    
    @derive Jason.Encoder
    defstruct Signalement.Commun.inherits_struct("nuisance_olfactive", type: nil, intensite: nil)

    use SignalNuisance.Model, as: SignalNuisance.Signalement
end