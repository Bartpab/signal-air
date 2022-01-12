defmodule SignalNuisance.Repo.Memoire do
    use GenServer

    def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    end

    @impl true
    def init(_opts) do
        {:ok, %{}}
    end

    defp assurer_table(état, type_entité) do
        unless Map.has_key?(état, type_entité) do
            état |> Map.put_new(type_entité, %{
                dernier_id: 0,
                entrées: []
            })
        else
            état
        end
    end

    @impl true
    def handle_call({cmd, type_entité, entité}, _from, état) when cmd == :creer do
        état = état |> assurer_table(type_entité)
        dernier_id = état[type_entité][:dernier_id]
        entité = entité |> Map.put(:id, dernier_id + 1)
        
        table = état[type_entité]
        table = table |> Map.put(:dernier_id, entité.id) |> Map.put(:entrées, [entité | table[:entrées]])
        état  = état |> Map.put(type_entité, table)

        {:reply, {:ok, entité}, état}
    end

    @impl true
    def handle_call({cmd, type_entité, id, modifications}, _from, état) when cmd == :modifier do
        état = état |> assurer_table(type_entité)

        table = état[type_entité]
        entrées = table[:entrées] 
        |> Enum.map(fn (x) -> 
            if x.id == id do
                Enum.reduce modifications, x, fn ({k, v}, acc) -> acc |> Map.put(k, v) end
            else
                x
            end
        end)
        table = table |> Map.put(:entrées, entrées)
        état = état |> Map.put(type_entité, table)
        {:reply, :ok, état}
    end

    @impl true
    def handle_call({cmd, type_entité, entité}, _from, état) when cmd == :existe do
        état = état |> assurer_table(type_entité)
        {:reply, état[type_entité][:entrées] |> Enum.any?((& &1.id == entité.id)), état}
    end

    @impl true
    def handle_call({cmd, type_entité, id}, _from, état) when cmd == :recuperer do
        état = état |> assurer_table(type_entité)  
        result = état[type_entité][:entrées] |> Enum.find((& &1.id == id))

        if result == nil do
            {:reply, {:error, :not_found}, état}
        else
            {:reply, {:ok, result}, état}
        end
    end

    @impl true
    def handle_call(:drop, _from, _état) do
        {:reply, :ok, %{}}
    end

    defp correspond?(entité, filtres) do
        filtres
        |> Enum.all?((& &1.(entité)))
    end

    defp trier_par(entités, []) do
        entités
    end

    defp trier_par(entités, [trier_par | tail]) do
        entités
        |> Enum.sort(fn (a, b) -> 
            case trier_par do 
                {trier_par, :desc} ->
                    val_a = a |> Map.from_struct |> Map.get(trier_par)
                    val_b = b |> Map.from_struct |> Map.get(trier_par) 
                    val_a >= val_b
                {trier_par, :asc} ->
                    val_a = a |> Map.from_struct |> Map.get(trier_par)
                    val_b = b |> Map.from_struct |> Map.get(trier_par) 
                    val_a <= val_b
                trier_par -> 
                    val_a = a |> Map.from_struct |> Map.get(trier_par)
                    val_b = b |> Map.from_struct |> Map.get(trier_par) 
                    val_a <= val_b
            end
        end)
        |> trier_par(tail)
    end

    defp limite(entités, limite) do
        case limite do
            x when x < 0 -> entités
            x when x >= 0 -> entités |> Enum.take(limite)
        end
    end

    def décalage(entités, décalage) do
        entités
        |> Enum.split(décalage)
        |> elem(1)
    end

    @impl true
    def handle_call({cmd, type_entité, opts}, _from, état) when cmd == :liste do
        état = état |> assurer_table(type_entité) 

        filtres = Keyword.get_values(opts, :ou)
        |> Enum.map(fn (x) -> 
            case x do
                [{k, v}] -> fn(entité) -> entité |> Map.get(k) == v end
                [{k, op, v}] ->  case op do
                    :gt -> fn(entité) -> entité  |> Map.get(k) > v end
                    :lt -> fn(entité) -> entité  |> Map.get(k) < v end
                    :gte -> fn(entité) -> entité |> Map.get(k) >= v end
                    :lte -> fn(entité) -> entité |> Map.get(k) <= v end
                    :eq -> fn(entité) -> entité  |> Map.get(k) == v end
                end
            end
        end)

        tris_par    = Keyword.get_values(opts, :trier_par) 
        limite      = Keyword.get(opts, :limite, -1) 
        décalage    = Keyword.get(opts, :décalage, 0)

        entrées = état[type_entité][:entrées] 
        |> Enum.filter(&correspond?(&1, filtres))
        |> trier_par(tris_par)
        |> décalage(décalage)
        |> limite(limite)

        {:reply, entrées, état}
    end

    def créer(%type_entité{} = entité, opts \\ []) when is_struct(entité) do
        type_entité = Keyword.get(opts, :as, type_entité)
        GenServer.call(__MODULE__, {:creer, type_entité, entité})
    end

    def modifier(type_entité, id, modifications) do
        GenServer.call(__MODULE__, {:modifier, type_entité, id, modifications})
    end

    def drop() do
        GenServer.call(__MODULE__, :drop)
    end

    def liste(type_entité, opts \\ []) do
        type_entité = Keyword.get(opts, :as, type_entité)
        GenServer.call(__MODULE__, {:liste, type_entité, opts})
    end

    def compte(type_entité, opts \\ []) do
        type_entité = Keyword.get(opts, :as, type_entité)
        GenServer.call(__MODULE__, {:liste, type_entité, opts}) |> length
    end

    def récupérer(type_entité, id, opts \\ []) do
        type_entité = Keyword.get(opts, :as, type_entité)
        GenServer.call(__MODULE__, {:recuperer, type_entité, id})
    end

    def existe?(%type_entité{} = entité, opts \\ []) do
        type_entité = Keyword.get(opts, :as, type_entité)
        GenServer.call(__MODULE__, {:existe, type_entité, entité})
    end
end