defmodule SignalNuisance.Fixture.Signalement.NuisanceOlfactive do
    def nouveau(opts \\ []) do
        obj = %SignalNuisance.Signalement.NuisanceOlfactive {
            long: 0.0, 
            lat:  0.0, 
            type: "Une odeur", 
            intensite: 3,
            signaler_par_id: "user:123",
            cree_le: "29/12/2021 14:14:14"
        }

        Enum.reduce opts, obj, fn({k, v}, acc) -> acc |> Map.put(k, v) end
    end

    def existant(opts \\ []) do
        obj = struct SignalNuisance.Signalement.NuisanceOlfactive, %{
            long: 0.0, 
            lat: 0.0,
            stype: "nuisance_olfactive", 
            id: "sig123",
            type: "Une odeur", 
            intensite: 3,
            cree_le: "29/12/2021 14:14:14"
          }

        Enum.reduce opts, obj, fn({k, v}, acc) -> if k in [:type, :intensite] do acc |> Map.put([:odeur, k], v) else acc |> Map.put(k, v) end end
    end
end