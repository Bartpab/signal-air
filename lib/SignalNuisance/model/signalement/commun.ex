defmodule SignalNuisance.Signalement.Commun do
    defstruct id: nil, stype: nil, nb_vues: 0, lat: nil, long: nil, par_id: nil, cree_le: Timex.now(), modifie_le: Timex.now(), cloture: false, cloture_le: nil

    def __changeset__, do: %{
        lat: :float,
        long: :float,
        par_id: :string
    }
    
    def base, do: [id: nil, nb_vues: 0, lat: nil, long: nil, par_id: nil, cree_le: Timex.now(), modifie_le: Timex.now(), cloture: false, cloture_le: nil]
    
    def inherits_changeset(opts \\ []) do
        Enum.reduce opts, __changeset__(), fn ({k, v}, acc) -> acc |> Map.put_new(k, v)  end
    end

    def inherits_struct(type, child_attrs \\ []) do
        [stype: type] ++ base() ++ child_attrs
    end
end