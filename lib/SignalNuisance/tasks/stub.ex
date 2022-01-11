defmodule SignalNuisance.Task.Stub do
    alias SignalNuisance.Signalement.NuisanceOlfactive
    alias SignalNuisance.Signalement
    alias SignalNuisance.HoraireProduction

    def loop(step \\ 100) do
        0..step |> Enum.each(fn (_x) -> step() end)
    end

    def step() do
        {s_prob, c_prob} = case HoraireProduction.liste(ou: [termine_le: nil]) do
            [] -> {0..5, 6..90}
            _ -> {0..50, 51..60}
        end

        ev = 0..100 |> Enum.random

        if ev in s_prob do
            signaler()
        end

        if ev in c_prob do
            cloturer()
        end
    end

    def signaler() do
        origin_lat =  48.779348845493196
        origin_long = 2.491707801818848

        v_lat = 48.787606316341574
        v_long = 2.4967718124389653

        t = (500..2500 |> Enum.random) / 1000
        t2 = (-1000..1000 |> Enum.random) / 1000

        spread_lat = (-2500..2500 |> Enum.random) / 1000
        spread_long = (-2500..2500 |> Enum.random) / 1000

        spread_angle = (:math.pi / 3) * t2

        u1_lat = (v_lat - origin_lat) * t
        u1_long = (v_long - origin_long) * t

        u_lat = u1_lat * :math.cos(spread_angle) - u1_long * :math.sin(spread_angle)
        u_long = u1_lat * :math.sin(spread_angle) + u1_long * :math.cos(spread_angle)

        u_lat = u_lat + origin_lat
        u_long = u_long + origin_long

        %{
            type: "Bitume",
            intensite: 1..3 |> Enum.random,
            par_id: "riverbot",
            lat: u_lat,
            long: u_long,
        } |> NuisanceOlfactive.créer
    end

    def cloturer() do
        case Signalement.liste(ou: [cloture: false], ou: [par_id: "riverbot"]) |> Enum.take_random(1) do
            [signalement] ->
                Signalement.cloturer(signalement)
            _ ->
        end
    end
end
