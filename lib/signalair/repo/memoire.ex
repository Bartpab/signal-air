defmodule SignalAir.Repo.Memoire do
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

    defp correspond?(entité, opts) do
        opts 
        |> Keyword.get_values(:where)
        |> Enum.all?((& &1.(entité)))
    end

    @impl true
    def handle_call({cmd, type_entité, opts}, _from, état) when cmd == :liste do
        état = état |> assurer_table(type_entité) 
        {:reply, état[type_entité][:entrées] |> Enum.filter(&correspond?(&1, opts)), état}
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

    def récupérer(type_entité, id, opts \\ []) do
        type_entité = Keyword.get(opts, :as, type_entité)
        GenServer.call(__MODULE__, {:recuperer, type_entité, id})
    end

    def existe?(%type_entité{} = entité, opts \\ []) do
        type_entité = Keyword.get(opts, :as, type_entité)
        GenServer.call(__MODULE__, {:existe, type_entité, entité})
    end
end