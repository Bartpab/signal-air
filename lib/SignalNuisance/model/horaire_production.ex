defmodule SignalNuisance.HoraireProduction do
    def __changeset__, do: %{
        entreprise_id: :integer,
        commence_le: :naive_datetime,
        termine_le: :naive_datetime
    }
    
    defstruct id: nil, entreprise_id: nil, commence_le: Timex.now(), termine_le: nil

    use SignalNuisance.Model
end