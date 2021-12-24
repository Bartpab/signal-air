defmodule SignalAirWeb.Report.NuisanceOlfactiveController do
    use SignalAirWeb, :controller

    alias SignalAir.Signalement.NuisanceOlfactive
    alias SignalAir.Signalement

    def list(conn, _) do
      conn |> render("list.html", signalements: Signalement.liste_nuisance_olfactive())
    end

    def create(conn, %{"nuisance_olfactive" => nuisance_olfactive_params}) do
      case Signalement.create_nuisance_olfactive(Map.merge(nuisance_olfactive_params, %{"cree_le" => DateTime.utc_now})) do
        {:ok, nuisance_olfactive} ->
          SignalAirWeb.Endpoint.broadcast("global", "nouveau_signalement", nuisance_olfactive)
          conn
          |> put_flash(:info, "Signalement crée avec succès.")
          |> redirect(to: Routes.page_path(conn, :index))
        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render_form(changeset)
        end
    end

    def render_form(conn, changeset) do
      conn |> render("new.html", 
        changeset: changeset,
        intensites_odeur: [
          [key: "Très forte", value: 3],
          [key: "Forte", value: 2], 
          [key: "Faible", value: 1], 
        ], type_odeurs: [
            "Bitumeux": ["Goudron"], 
            "Chimique": ["Ammoniac"], 
            "Organique": ["Egout", "Oeuf pourri"]
        ]
      )
    end

    def new(conn, _params) do
      conn 
      |> render_form(NuisanceOlfactive.changeset(%NuisanceOlfactive{}, %{}))
    end
  end
  