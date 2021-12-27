defmodule SignalAirWeb.Monitoring.EntrepriseLive do
    use SignalAirWeb, :live_view

    alias SignalAir.Signalement.NuisanceOlfactive
    alias SignalAir.Signalement
    
    def render(assigns) do
      ~H"""
        <h1><%= gettext "Surveillance temps-réel" %></h1>

        <h2><%= gettext "Carte" %> <a class="btn btn-primary mb-3" onclick="$component.recupererGeolocalisation()"><i class="bi bi-geo-alt"></i></a></h2>
        <section id="section-carte" class="row" phx-update="ignore" phx-hook="GestionnaireCarte">
          <div id="carte" style="height: 400px">
          </div>
        </section>

        <h2><%= gettext "Derniers signalements" %></h2>
        <%= for signalement <- @signalements do %>
          <div class="card">
            <div class="card-body">
            <h5 class="card-title">Nuisance olfactive</h5>
            <h6 class="card-subtitle mb-2 text-muted"><%= signalement.intensite_odeur %> | <%= signalement.cree_le %></h6>
            <p class="card-text"><%= signalement.type_odeur %></p>
            </div>
          </div>
        <% end %>

        <script type="text/javascript">
          let $component = Object.create({
            carte: null,
            async recupererGeolocalisation() {
              let coords = await recupererGeolocalisation();
              this.carte.setView([coords.latitude, coords.longitude], 16, { animation: true });     
            },
            ready() {

              var PlanIGN = L.tileLayer('https://wxs.ign.fr/{ignApiKey}/geoportail/wmts?'+
                  '&REQUEST=GetTile&SERVICE=WMTS&VERSION=1.0.0&TILEMATRIXSET=PM'+
                  '&LAYER={ignLayer}&STYLE={style}&FORMAT={format}'+
                  '&TILECOL={x}&TILEROW={y}&TILEMATRIX={z}',
                  {
                    ignApiKey: 'pratique',
                    ignLayer: 'GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2',
                    style: 'normal',
                    format: 'image/png',
                    service: 'WMTS',
              });
              this.marks = [
                <%= for signalement <- @signalements do %>
                  [<%= signalement.lat %>, <%= signalement.long %>],
                <% end %>
              ];
              this.carte = L.map('carte', {center: [48.78254197659407, 2.493269270679186], zoom: 16, layers: [PlanIGN]});

              this.marks.forEach(function (mark) {
                L.circle(mark, {color: 'red', opacity: 0.5, radius: 100, fillColor: '#f03', fillOpacity: 0.5}).addTo(this.carte);
              }.bind(this))
            }
          });

          $(document).ready(function() {
            $component.ready();
            liveSocket.hooks.GestionnaireCarte = {
              mounted() {
                this.handleEvent("nouveau_signalement", function(signalement) {
                  console.log("Nouveau signalement reçu !");
                  let coords = [signalement.lat, signalement.long];
                  L.circle(coords, {color: 'red', opacity: 0.5, radius: 100, fillColor: '#f03', fillOpacity: 0.5}).addTo($component.carte);
                });
              }
            };
          });
        </script>

      """
    end

    def handle_info(msg, %{assigns: %{signalements: signalements}} = socket) do
      case msg do
        %Phoenix.Socket.Broadcast{
          topic: "global", 
          event: "nouveau_signalement", 
          payload: signalement
        } -> {:noreply, 
            socket 
              |> assign(:signalements, [signalement | signalements])
              |> push_event("nouveau_signalement", signalement)
          }
        _ -> {:noreply, socket}
      end

    end
    

    def handle_event(event, _params, socket) do
      IO.inspect(event)
      {:noreply, socket}
    end

    def mount(_params, _session, socket) do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(SignalAir.PubSub, "global")
      end

      {:ok, socket |> assign(:signalements, Signalement.liste_nuisance_olfactive())}
    end

end
  