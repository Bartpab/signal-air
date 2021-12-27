defmodule SignalAir.Repo.Migrations.CreateSignalementNuisancesOlfactives do
  use Ecto.Migration

  def change do
    create table(:signalement_nuisances_olfactives) do
      add :type_odeur, :string
      add :intensite_odeur, :integer
      add :lat, :float
      add :long, :float
      add :cree_le, :naive_datetime

      timestamps()
    end
  end
end
