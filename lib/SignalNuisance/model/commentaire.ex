defmodule SignalNuisance.Commentaire do
    alias SignalNuisance.Model

    @repo Application.get_env(:SignalNuisance, :repo)

    def __changeset__, do: %{
        parent_id: :string,
        par_id: :string,
        contenu: :string,
        crée_le: :naive_datetime
    }
    
    defstruct id: nil, parent_id: nil, contenu: nil, par_id: nil, crée_le: Timex.now(), children: []

    def changeset(attrs \\ %{}, opts \\ []) do
        %__MODULE__{} 
            |> Ecto.Changeset.cast(attrs, Map.keys(__changeset__())) 
            |> (& if Keyword.has_key?(opts, :validate), do: &1 |> Ecto.Changeset.validate_required(Map.keys(__changeset__())), else: &1 ).()
    end

    def créer(commentaire_params, opts \\ []) do
        changeset = commentaire_params |> Map.put("crée_le", Timex.now()) |> changeset(validate: true)
        
        with true <- changeset.valid?,
            {:ok, commentaire} <- changeset |> Ecto.Changeset.apply_changes |> @repo.créer
        do
            notifier(:nouveau_commentaire, commentaire)
        end
    end

    defp notifier(:nouveau_commentaire, commentaire) do
        SignalNuisanceWeb.Endpoint.broadcast("global", "nouveau_commentaire", commentaire) 
        SignalNuisanceWeb.Endpoint.broadcast(commentaire.parent_id, "nouveau_commentaire", commentaire) 
        {:ok, commentaire}
    end

    def liste(opts \\ []) do
        filter = opts
        |> Enum.filter((& &1 in [:crée_le, :parent_id, :parent, :contenu, :par_id]))
        |> Enum.map(fn ({k, v}) -> 
            case {k, v} do
                {:parent, %{type: type, id: id} } -> {:where, fn (x) -> Map.get(x, :parent_id) == Model.global_id(type, id) end} 
                _ -> {:where, fn (x) -> Map.get(x, k) == v end} 
            end
            
        end)
        
        result = __MODULE__ |> @repo.liste(filter)
        
        case {result, Keyword.has_key?(opts, :include_children)} do
            {{:ok, entities}, true} ->
                entities
                |> Enum.map(fn (entity) -> 
                    case liste(parent: %{type: __MODULE__, id: entity.id}) do
                        {:ok, children} -> entity |> Map.put(:children, children)
                        _ -> entity
                    end
                end)
                
            _ -> result
        end
    end
end