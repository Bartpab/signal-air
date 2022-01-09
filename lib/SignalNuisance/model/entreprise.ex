defmodule SignalNuisance.Entreprise do
    @repo Application.get_env(:SignalNuisance, :repo)

    def __changeset__, do: %{
        name: :string,
        slug: :string,
        lat: :float,
        long: :float
    }
    
    defstruct id: nil, name: nil, slug: nil, lat: nil, long: nil

    use SignalNuisance.Model

end