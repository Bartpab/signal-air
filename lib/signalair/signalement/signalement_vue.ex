defmodule SignalAir.Signalement.Vue do
    alias SignalAir.Signalement

    import Ecto.Query, warn: false
    alias SignalAir.Repo
    
    use Ecto.Schema
    import Ecto.Changeset
  
    @derive {Jason.Encoder, only: [:vu_par_id, :vu_le]}
    schema "signalement_vues" do
      field :vu_par_id, :string
      belongs_to :signalement, SignalAir.Signalement
      timestamps(inserted_at: :vu_le)
    end
  
    @doc false
    def changeset(vue, attrs) do
      vue
      |> cast(attrs, [:vu_par_id, :signalement_id])
      |> validate_required([:vu_par_id, :signalement_id])
    end
end