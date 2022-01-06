defmodule SignalNuisance.VueSignalement do
    def __changeset__, do: %{
        signalement_id: :string,
        vu_par_id: :string,
        vu_le: :naive_datetime
    }
    
    defstruct id: nil, signalement_id: nil, vu_par_id: nil, vue_le: Timex.now()

end