defmodule SignalNuisance.HoraireProduction do
    def __changeset__, do: %{
        entreprise_id: :integer,
        commence_le: :naive_datetime
    }
    
    defstruct id: nil, entreprise_id: nil, commence_le: Timex.now(), termine_le: nil

    use SignalNuisance.Model

    def en_cours(entreprise_id) do
        entreprise_id = case entreprise_id do
            %SignalNuisance.Entreprise{id: entreprise_id} -> entreprise_id
            _ -> entreprise_id
        end
        
        liste(ou: [entreprise_id: entreprise_id], ou: [termine_le: nil])
    end

    def commencer(entreprise_id) do
        entreprise_id = case entreprise_id do
            %SignalNuisance.Entreprise{id: entreprise_id} -> entreprise_id
            _ -> entreprise_id
        end
        
        case liste(ou: [entreprise_id: entreprise_id], ou: [termine_le: nil]) do
            [] -> 
                %{entreprise_id: entreprise_id, commence_le: Timex.now()} |> créer   
            _ -> 
        end
    end

    def terminer(entreprise_id) do
        entreprise_id = case entreprise_id do
            %SignalNuisance.Entreprise{id: entreprise_id} -> entreprise_id
            _ -> entreprise_id
        end
        
        case liste(ou: [entreprise_id: entreprise_id], ou: [termine_le: nil]) do
            [horaire] -> 
                modifier(horaire.id, [termine_le: Timex.now()])  
            _ ->
        end
    end
end