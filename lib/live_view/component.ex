defmodule SignalNuisance.LiveComponent do
    defmacro __using__(opts) do
        quote do
            def send_event(socket, component \\ nil, event, payload) do
                cid = case component do
                %Phoenix.LiveComponent.CID{cid: cid} -> cid
                _ -> nil
                end
            
                send(
                socket.root_pid,
                %Phoenix.Socket.Message{
                    event: "event",
                    join_ref: nil,
                    payload: %{
                    "cid" => cid,
                    "event" => event,
                    "type" => "other",
                    "value" => payload
                    },
                    ref: nil,
                    topic: "lv:" <> socket.id
                }
                )
            end
        end
    end
end