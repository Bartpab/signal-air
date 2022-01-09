defmodule SignalNuisance.Model do
    def global_id(%type{id: id}) do
        type = case type do
            SignalNuisance.Entreprise -> "entreprise"
            SignalNuisance.Commentaire -> "commentaire"
            SignalNuisance.Signalement -> "signalement"
            SignalNuisance.Signalement.NuisanceOlfactive -> "signalement"
            _ -> "?"
        end

        "#{type}:#{id}"
    end

    def global_id(type, id) do
        type = case type do
            SignalNuisance.Entreprise -> "entreprise"
            SignalNuisance.Commentaire -> "commentaire"
            SignalNuisance.Signalement -> "signalement"
            SignalNuisance.Signalement.NuisanceOlfactive -> "signalement"
            _ -> "?"
        end

        "#{type}:#{id}"
    end
    
    defmacro __using__(_opts) do
        quote do
            @repo Application.get_env(:SignalNuisance, :repo)
            
            def changeset(attrs \\ %{}, opts \\ []) do
                %__MODULE__{} 
                    |> Ecto.Changeset.cast(attrs, Map.keys(__changeset__())) 
                    |> (& if Keyword.has_key?(opts, :validate), do: &1 |> Ecto.Changeset.validate_required(Map.keys(__changeset__())), else: &1 ).()
            end

            def créer(params, opts \\ []) do               
                chgset = params |> changeset(validate: true)
                
                with true <- chgset.valid?,
                    {:ok, entité} <- chgset |> Ecto.Changeset.apply_changes |> @repo.créer
                do
                    SignalNuisanceWeb.Endpoint.broadcast("global", "nouveau", {__MODULE__, entité}) 
                    {:ok, entité}
                end
            end

            def modifier(id, modifications) do
                retval = __MODULE__ |> @repo.modifier(id, modifications)
                SignalNuisanceWeb.Endpoint.broadcast("global", "modification", {__MODULE__, id, modifications}) 
                retval
            end

            def récupérer!(id) do
                case __MODULE__ |> @repo.récupérer(id) do
                    {:ok, entité} -> entité
                    _ -> raise "#{__MODULE__} n° #{id} non trouvé."
                end
            end
        
            def récupérer(id) do
                __MODULE__ |> @repo.récupérer(id)
            end
        
            def liste(opts \\ []) do
                opts = opts 
                |> Enum.map(fn ({k, v}) -> {:where, fn (x) -> Map.get(x, k) == v end} end)
                __MODULE__ |> @repo.liste(opts)
            end
        end
    end


end