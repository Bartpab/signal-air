defmodule SignalAir.Repo.Ecto do
  use Ecto.Repo,
    otp_app: :SignalAir,
    adapter: Etso.Adapter
end
