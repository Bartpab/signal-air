defmodule SignalNuisance.Commentaire do
    @repo Application.get_env(:SignalNuisance, :repo)

    def __changeset__, do: %{
        parent_id: :string,
        par_id: :string,
        contenu: :string
    }
    
    defstruct id: nil, parent_id: nil, contenu: nil, par_id: nil, crée_le: Timex.now(), children: []

    use SignalNuisance.Model
end