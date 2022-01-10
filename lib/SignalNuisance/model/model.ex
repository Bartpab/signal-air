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
    
    defmacro __using__(mod_opts) do
        [quote do
            @repo Application.get_env(:SignalNuisance, :repo)
        end,

        unless Keyword.get(mod_opts, :polymorphism, false) do
            quote do
                def changeset(attrs \\ %{}, opts \\ []) do
                    %__MODULE__{} 
                        |> Ecto.Changeset.cast(attrs, Map.keys(__changeset__())) 
                        |> (& if Keyword.has_key?(opts, :validate), do: &1 |> Ecto.Changeset.validate_required(Map.keys(__changeset__())), else: &1 ).()
                end
    
                def créer(params, opts \\ []) do         
                    as = unquote(Keyword.get(mod_opts, :as, nil))
                    as = if as == nil do __MODULE__ else as end
                    
                    chgset = params |> changeset(validate: true)
                    
                    with true <- chgset.valid?,
                        {:ok, entité} <- chgset |> Ecto.Changeset.apply_changes |> @repo.créer(as: as)
                    do
                        SignalNuisanceWeb.Endpoint.broadcast("global", "nouveau", {as, entité}) 
                        {:ok, entité}
                    end
                end
            end
        end,

        quote do
            def modifier(id, modifications) do
                as = unquote(Keyword.get(mod_opts, :as, nil))
                as = if as == nil do __MODULE__ else as end

                retval = __MODULE__ |> @repo.modifier(id, modifications)
                SignalNuisanceWeb.Endpoint.broadcast("global", "modification", {as, id, modifications}) 
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
        
            def compte(opts \\ []) do
                __MODULE__ |> @repo.compte(opts)
            end

            def liste(opts \\ []) do
                __MODULE__ |> @repo.liste(opts)
            end
        end]
    end


end