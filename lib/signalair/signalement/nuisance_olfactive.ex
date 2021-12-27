defmodule SignalAir.Signalement.NuisanceOlfactive do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:cree_le, :intensite_odeur, :lat, :long, :type_odeur]}
  schema "signalement_nuisances_olfactives" do
    field :cree_le, :naive_datetime
    field :intensite_odeur, :integer
    field :lat, :float
    field :long, :float
    field :type_odeur, :string

    timestamps()
  end

  @doc false
  def changeset(nuisance_olfactive, attrs) do
    nuisance_olfactive
    |> cast(attrs, [:type_odeur, :intensite_odeur, :lat, :long, :cree_le])
    |> validate_required([:type_odeur, :intensite_odeur, :lat, :long, :cree_le])
  end
end
