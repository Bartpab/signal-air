defmodule SignalNuisance.Task.Installer do
    def reinstall() do
        SignalNuisance.Repo.Memoire.drop()
    end

    def install() do
    end
end