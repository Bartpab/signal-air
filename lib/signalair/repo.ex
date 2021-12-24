defmodule SignalAir.Repo do
  use Ecto.Repo,
    otp_app: :SignalAir,
    adapter: Etso.Adapter
end
