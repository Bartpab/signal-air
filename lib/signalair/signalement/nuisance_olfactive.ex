defmodule SignalAir.Signalement.NuisanceOlfactive do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:intensite, :type]}
  schema "signalement_nuisances_olfactives" do
    field :intensite, :integer
    field :type, :string
    
    belongs_to :signalement, SignalAir.Signalement
  end

  @doc false
  def changeset(nuisance_olfactive, attrs) do
    nuisance_olfactive
    |> cast(attrs, [:type, :intensite])
    |> validate_required([:type, :intensite])
  end
end
