defmodule SignalNuisance.Signalement.NuisanceOlfactive do
    def __changeset__, do: SignalNuisance.Signalement.Commun.inherits_changeset type: :string,  intensite: :integer
    
    @derive Jason.Encoder
    defstruct SignalNuisance.Signalement.Commun.inherits_struct("nuisance_olfactive", type: nil, intensite: nil)

    use SignalNuisance.Model, as: SignalNuisance.Signalement
end