defmodule SignalAirWeb.Signalement.NuisanceOlfactiveController do
    use SignalAirWeb, :controller

    alias SignalAir.Signalement.NuisanceOlfactive
    alias SignalAir.Signalement

    def create(conn, %{"nuisance_olfactive" => nuisance_olfactive_params}) do
      case nuisance_olfactive_params |> Map.put("signaler_par_id", conn.assigns[:client_id]) |> Signalement.creer_nuisance_olfactive do
        {:ok, nuisance_olfactive} ->
          conn
            |> put_flash(:info, "Signalement crée avec succès.")
            |> redirect(to: Routes.live_path(conn, SignalAirWeb.Surveillance.CitoyenLive))
        {:error, %Ecto.Changeset{} = changeset} -> 
          conn |> render_form(changeset)
      end
    end

    def render_form(conn, changeset) do
      conn |> render("new.html", 
        changeset: changeset,
        intensites: [
          [key: "Très forte", value: 3],
          [key: "Forte", value: 2], 
          [key: "Faible", value: 1], 
        ], types: [
            "Bitumeux": ["Goudron"], 
            "Chimique": ["Ammoniac"], 
            "Organique": ["Egout", "Oeuf pourri"]
        ]
      )
    end

    def new(conn, _params) do
      conn |> render_form(NuisanceOlfactive.changeset(%NuisanceOlfactive{}, %{}))
    end
  end
  