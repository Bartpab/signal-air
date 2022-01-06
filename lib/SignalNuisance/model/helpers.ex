defmodule SignalNuisance.Model do
    def global_id(type, id) do
        type = case type do
            SignalNuisance.Commentaire -> "commentaire"
            SignalNuisance.Signalement -> "signalement"
            SignalNuisance.Signalement.NuisanceOlfactive -> "signalement"
            _ -> "?"
        end

        "#{type}:#{id}"
    end
end