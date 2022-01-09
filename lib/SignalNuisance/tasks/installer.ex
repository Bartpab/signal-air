defmodule SignalNuisance.Task.Installer do
    def reinstall() do
        SignalNuisance.Repo.Memoire.drop()
    end

    def install() do
        %{name: "Acme", slug: "acme", long: 2.491707801818848, lat: 48.779348845493196} |> SignalNuisance.Entreprise.créer
    end
end