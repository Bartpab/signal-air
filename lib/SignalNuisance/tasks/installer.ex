defmodule SignalNuisance.Task.Installer do
    def reinstall() do
        SignalNuisance.Repo.Memoire.drop()
        install()
    end

    def install() do
        %{name: "Acme", slug: "acme", long: 2.491707801818848, lat: 48.779348845493196} |> SignalNuisance.Entreprise.créer
        SignalNuisance.Task.Stub.loop(100)
    end
end