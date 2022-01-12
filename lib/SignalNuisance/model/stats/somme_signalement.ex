defmodule SignalNuisance.Stats.SommeSignalementEnCours do
    @repo Application.get_env(:SignalNuisance, :repo)

    def __changeset__, do: %{
        v: :integer,
        f: :string,
        t: :naive_datetime
    }
    
    defstruct id: nil, v: nil, f: nil, t: Timex.now()

    use SignalNuisance.Model
end