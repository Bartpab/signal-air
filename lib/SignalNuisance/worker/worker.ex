defmodule SignalNuisance.Worker do
    use GenServer

    def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    end

    @impl true
    def init(opts) do
        Phoenix.PubSub.subscribe(SignalNuisance.PubSub, "global")
        {:ok, %{}}
    end

    def handle_info(msg, état) do
        case msg do
          %Phoenix.Socket.Broadcast {
            topic: "global",
            event: "nouveau",
            payload: {SignalNuisance.Commentaire, commentaire}
          } ->
            if commentaire.parent_id |> String.starts_with?("signalement:") do
                signalement_id = commentaire.parent_id
                |> String.replace("signalement:", "")
                |> String.to_integer

                SignalNuisance.Signalement.modifier(signalement_id, [modifie_le: commentaire.crée_le])
            end
            {:noreply, état}
          _ -> {:noreply, état}
        end
      end
end
