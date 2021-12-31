defmodule SignalAir.Signalement.Commun do
    defstruct id: nil, stype: nil, nb_vues: 0, lat: nil, long: nil, signaler_par_id: nil, cree_le: DateTime.now!("Etc/UTC")

    def __changeset__, do: %{
        nb_vues: :integer,
        lat: :float,
        long: :float,
        signaler_par_id: :string,
        cree_le: :naive_datetime
    }
    
    def base, do: [id: nil, nb_vues: 0, lat: nil, long: nil, signaler_par_id: nil, cree_le: DateTime.now!("Etc/UTC")]
    
    def inherits_changeset(opts \\ []) do
        Enum.reduce opts, __changeset__(), fn ({k, v}, acc) -> acc |> Map.put_new(k, v)  end
    end

    def inherits_struct(type, child_attrs \\ []) do
        [stype: type] ++ base() ++ child_attrs
    end
end