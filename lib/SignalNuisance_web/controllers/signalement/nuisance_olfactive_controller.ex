defmodule SignalNuisanceWeb.Signalement.NuisanceOlfactiveController do
    use SignalNuisanceWeb, :controller

    alias SignalNuisance.Signalement

    def create(conn, %{"nuisance_olfactive" => params}) do
      with {:ok, _signalement} <- params
      |> Map.put("signaler_par_id", conn.assigns[:client_id])
      |> Signalement.NuisanceOlfactive.validate
      |> Signalement.créer
        do
          conn
          |> put_flash(:info, "Signalement crée avec succès.")
          |> redirect(to: Routes.live_path(conn, SignalNuisanceWeb.Surveillance.CitoyenLive))            
        else
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
      conn |> render_form(SignalNuisance.Signalement.NuisanceOlfactive.changeset())
    end
  end
  