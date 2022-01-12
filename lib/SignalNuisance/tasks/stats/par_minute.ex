defmodule SignalNuisance.Task.Stats.ParMinute do
    alias SignalNuisance.Signalement

    def somme_signalements_en_cours do
        %{t: Timex.now(), f: "minute", v: Signalement.compte(ou: [cloture: false])}
        |> SignalNuisance.Stats.SommeSignalementEnCours.créer
    end
end