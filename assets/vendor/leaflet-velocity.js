"use strict";L.DomUtil.setTransform||(L.DomUtil.setTransform=function(t,e,n){var i=e||new L.Point(0,0);t.style[L.DomUtil.TRANSFORM]=(L.Browser.ie3d?"translate("+i.x+"px,"+i.y+"px)":"translate3d("+i.x+"px,"+i.y+"px,0)")+(n?" scale("+n+")":"")}),L.CanvasLayer=(L.Layer?L.Layer:L.Class).extend({initialize:function(t){this._map=null,this._canvas=null,this._frame=null,this._delegate=null,L.setOptions(this,t)},delegate:function(t){return this._delegate=t,this},needRedraw:function(){return this._frame||(this._frame=L.Util.requestAnimFrame(this.drawLayer,this)),this},_onLayerDidResize:function(t){this._canvas.width=t.newSize.x,this._canvas.height=t.newSize.y},_onLayerDidMove:function(){var t=this._map.containerPointToLayerPoint([0,0]);L.DomUtil.setPosition(this._canvas,t),this.drawLayer()},getEvents:function(){var t={resize:this._onLayerDidResize,moveend:this._onLayerDidMove};return this._map.options.zoomAnimation&&L.Browser.any3d&&(t.zoomanim=this._animateZoom),t},onAdd:function(t){console.log("canvas onAdd",this),this._map=t,this._canvas=L.DomUtil.create("canvas","leaflet-layer"),this.tiles={};var e=this._map.getSize();this._canvas.width=e.x,this._canvas.height=e.y;var n=this._map.options.zoomAnimation&&L.Browser.any3d;L.DomUtil.addClass(this._canvas,"leaflet-zoom-"+(n?"animated":"hide")),this.options.pane.appendChild(this._canvas),t.on(this.getEvents(),this);var i=this._delegate||this;i.onLayerDidMount&&i.onLayerDidMount(),this.needRedraw();var o=this;setTimeout(function(){o._onLayerDidMove()},0)},onRemove:function(t){var e=this._delegate||this;e.onLayerWillUnmount&&e.onLayerWillUnmount(),this.options.pane.removeChild(this._canvas),t.off(this.getEvents(),this),this._canvas=null},addTo:function(t){return t.addLayer(this),this},drawLayer:function(){var t=this._map.getSize(),e=this._map.getBounds(),n=this._map.getZoom(),i=this._map.options.crs.project(this._map.getCenter()),o=this._map.options.crs.project(this._map.containerPointToLatLng(this._map.getSize())),a=this._delegate||this;a.onDrawLayer&&a.onDrawLayer({layer:this,canvas:this._canvas,bounds:e,size:t,zoom:n,center:i,corner:o}),this._frame=null},_setTransform:function(t,e,n){var i=e||new L.Point(0,0);t.style[L.DomUtil.TRANSFORM]=(L.Browser.ie3d?"translate("+i.x+"px,"+i.y+"px)":"translate3d("+i.x+"px,"+i.y+"px,0)")+(n?" scale("+n+")":"")},_animateZoom:function(t){var e=this._map.getZoomScale(t.zoom),n=L.Layer?this._map._latLngToNewLayerPoint(this._map.getBounds().getNorthWest(),t.zoom,t.center):this._map._getCenterOffset(t.center)._multiplyBy(-e).subtract(this._map._getMapPanePos());L.DomUtil.setTransform(this._canvas,n,e)}}),L.canvasLayer=function(t){return new L.CanvasLayer(t)},L.Control.Velocity=L.Control.extend({options:{position:"bottomleft",emptyString:"Unavailable",angleConvention:"bearingCCW",showCardinal:!1,speedUnit:"m/s",directionString:"Direction",speedString:"Speed",onAdd:null,onRemove:null},onAdd:function(t){return this._container=L.DomUtil.create("div","leaflet-control-velocity"),L.DomEvent.disableClickPropagation(this._container),t.on("mousemove",this._onMouseMove,this),this._container.innerHTML=this.options.emptyString,this.options.leafletVelocity.options.onAdd&&this.options.leafletVelocity.options.onAdd(),this._container},onRemove:function(t){t.off("mousemove",this._onMouseMove,this),this.options.leafletVelocity.options.onRemove&&this.options.leafletVelocity.options.onRemove()},vectorToSpeed:function(t,e,n){var i=Math.sqrt(Math.pow(t,2)+Math.pow(e,2));return"k/h"===n?this.meterSec2kilometerHour(i):"kt"===n?this.meterSec2Knots(i):"mph"===n?this.meterSec2milesHour(i):i},vectorToDegrees:function(t,e,n){n.endsWith("CCW")&&(e=0<e?e=-e:Math.abs(e));var i=Math.sqrt(Math.pow(t,2)+Math.pow(e,2)),o=180*Math.atan2(t/i,e/i)/Math.PI+180;return"bearingCW"!==n&&"meteoCCW"!==n||360<=(o+=180)&&(o-=360),o},degreesToCardinalDirection:function(t){var e="";return 0<=t&&t<11.25||348.75<=t?e="N":11.25<=t&&t<33.75?e="NNW":33.75<=t&&t<56.25?e="NW":56.25<=t&&t<78.75?e="WNW":78.25<=t&&t<101.25?e="W":101.25<=t&&t<123.75?e="WSW":123.75<=t&&t<146.25?e="SW":146.25<=t&&t<168.75?e="SSW":168.75<=t&&t<191.25?e="S":191.25<=t&&t<213.75?e="SSE":213.75<=t&&t<236.25?e="SE":236.25<=t&&t<258.75?e="ESE":258.75<=t&&t<281.25?e="E":281.25<=t&&t<303.75?e="ENE":303.75<=t&&t<326.25?e="NE":326.25<=t&&t<348.75&&(e="NNE"),e},meterSec2Knots:function(t){return t/.514},meterSec2kilometerHour:function(t){return 3.6*t},meterSec2milesHour:function(t){return 2.23694*t},_onMouseMove:function(t){var e=this.options.leafletVelocity._map.containerPointToLatLng(L.point(t.containerPoint.x,t.containerPoint.y)),n=this.options.leafletVelocity._windy.interpolatePoint(e.lng,e.lat),i="";if(n&&!isNaN(n[0])&&!isNaN(n[1])&&n[2]){var o=this.vectorToDegrees(n[0],n[1],this.options.angleConvention),a=this.options.showCardinal?" (".concat(this.degreesToCardinalDirection(o),") "):"";i="<strong> ".concat(this.options.velocityType," ").concat(this.options.directionString,": </strong> ").concat(o.toFixed(2),"°").concat(a,", <strong> ").concat(this.options.velocityType," ").concat(this.options.speedString,": </strong> ").concat(this.vectorToSpeed(n[0],n[1],this.options.speedUnit).toFixed(2)," ").concat(this.options.speedUnit)}else i=this.options.emptyString;this._container.innerHTML=i}}),L.Map.mergeOptions({positionControl:!1}),L.Map.addInitHook(function(){this.options.positionControl&&(this.positionControl=new L.Control.MousePosition,this.addControl(this.positionControl))}),L.control.velocity=function(t){return new L.Control.Velocity(t)},L.VelocityLayer=(L.Layer?L.Layer:L.Class).extend({options:{displayValues:!0,displayOptions:{velocityType:"Velocity",position:"bottomleft",emptyString:"No velocity data"},maxVelocity:10,colorScale:null,data:null},_map:null,_canvasLayer:null,_windy:null,_context:null,_timer:0,_mouseControl:null,initialize:function(t){L.setOptions(this,t)},onAdd:function(t){this._paneName=this.options.paneName||"overlayPane";var e=t._panes.overlayPane;t.getPane&&(e=(e=t.getPane(this._paneName))||t.createPane(this._paneName)),this._canvasLayer=L.canvasLayer({pane:e}).delegate(this),this._canvasLayer.addTo(t),this._map=t},onRemove:function(t){this._destroyWind()},setData:function(t){this.options.data=t,this._windy&&(this._windy.setData(t),this._clearAndRestart()),this.fire("load")},setOpacity:function(t){console.log("this._canvasLayer",this._canvasLayer),this._canvasLayer.setOpacity(t)},setOptions:function(t){this.options=Object.assign(this.options,t),t.hasOwnProperty("displayOptions")&&(this.options.displayOptions=Object.assign(this.options.displayOptions,t.displayOptions),this._initMouseHandler(!0)),t.hasOwnProperty("data")&&(this.options.data=t.data),this._windy&&(this._windy.setOptions(t),t.hasOwnProperty("data")&&this._windy.setData(t.data),this._clearAndRestart()),this.fire("load")},onDrawLayer:function(t,e){var n=this;this._windy?this.options.data&&(this._timer&&clearTimeout(n._timer),this._timer=setTimeout(function(){n._startWindy()},750)):this._initWindy(this)},_startWindy:function(){var t=this._map.getBounds(),e=this._map.getSize();this._windy.start([[0,0],[e.x,e.y]],e.x,e.y,[[t._southWest.lng,t._southWest.lat],[t._northEast.lng,t._northEast.lat]])},_initWindy:function(t){var e=Object.assign({canvas:t._canvasLayer._canvas,map:this._map},t.options);this._windy=new Windy(e),this._context=this._canvasLayer._canvas.getContext("2d"),this._canvasLayer._canvas.classList.add("velocity-overlay"),this.onDrawLayer(),this._map.on("dragstart",t._windy.stop),this._map.on("dragend",t._clearAndRestart),this._map.on("zoomstart",t._windy.stop),this._map.on("zoomend",t._clearAndRestart),this._map.on("resize",t._clearWind),this._initMouseHandler(!1)},_initMouseHandler:function(t){if(t&&(this._map.removeControl(this._mouseControl),this._mouseControl=!1),!this._mouseControl&&this.options.displayValues){var e=this.options.displayOptions||{};(e.leafletVelocity=this)._mouseControl=L.control.velocity(e).addTo(this._map)}},_clearAndRestart:function(){this._context&&this._context.clearRect(0,0,3e3,3e3),this._windy&&this._startWindy()},_clearWind:function(){this._windy&&this._windy.stop(),this._context&&this._context.clearRect(0,0,3e3,3e3)},_destroyWind:function(){this._timer&&clearTimeout(this._timer),this._windy&&this._windy.stop(),this._context&&this._context.clearRect(0,0,3e3,3e3),this._mouseControl&&this._map.removeControl(this._mouseControl),this._mouseControl=null,this._windy=null,this._map.removeLayer(this._canvasLayer)}}),L.velocityLayer=function(t){return new L.VelocityLayer(t)};var Windy=function(S){function o(t,e,n,i,o,a){var r=1-t,s=1-e,l=r*s,h=t*s,c=r*e,d=t*e,p=n[0]*l+i[0]*h+o[0]*c+a[0]*d,u=n[1]*l+i[1]*h+o[1]*c+a[1]*d;return[p,u,Math.sqrt(p*p+u*u)]}function d(t){var e=null,n=null;return t.forEach(function(t){switch(t.header.parameterCategory+","+t.header.parameterNumber){case"1,2":case"2,2":e=t;break;case"1,3":case"2,3":n=t;break;default:t}}),function(t,e){var n=t.data,i=e.data;return{header:t.header,data:function(t){return[n[t],i[t]]},interpolate:o}}(e,n)}function a(i,o,t){function a(t,e){var n=i[Math.round(t)];return n&&n[Math.round(e)]||h}a.release=function(){i=[]},a.randomize=function(t){for(var e,n,i=0;null===a(e=Math.round(Math.floor(Math.random()*o.width)+o.x),n=Math.round(Math.floor(Math.random()*o.height)+o.y))[2]&&i++<30;);return t.x=e,t.y=n,t},t(o,a)}function r(t){return t/180*Math.PI}function s(i,s){var e,n,l=(e=x,n=C,R.indexFor=function(t){return Math.max(0,Math.min(R.length-1,Math.round((t-e)/(n-e)*(R.length-1))))},R),h=l.map(function(){return[]}),t=Math.round(i.width*i.height*D);/android|blackberry|iemobile|ipad|iphone|ipod|opera mini|webos/i.test(navigator.userAgent)&&(t*=T);for(var o="rgba(0, 0, 0, ".concat(O,")"),a=[],r=0;r<t;r++)a.push(s.randomize({age:Math.floor(Math.random()*P)+0}));var c=S.canvas.getContext("2d");c.lineWidth=b,c.fillStyle=o,c.globalAlpha=.6;var d=Date.now();!function t(){M=requestAnimationFrame(t);var e=Date.now(),n=e-d;W<n&&(d=e-n%W,h.forEach(function(t){t.length=0}),a.forEach(function(t){t.age>P&&(s.randomize(t).age=0);var e=t.x,n=t.y,i=s(e,n),o=i[2];if(null===o)t.age=P;else{var a=e+i[0],r=n+i[1];null!==s(a,r)[2]?(t.xt=a,t.yt=r,h[l.indexFor(o)].push(t)):(t.x=a,t.y=r)}t.age+=1}),c.globalCompositeOperation="destination-in",c.fillRect(i.x,i.y,i.width,i.height),c.globalCompositeOperation="lighter",c.globalAlpha=0===O?0:.9*O,h.forEach(function(t,e){0<t.length&&(c.beginPath(),c.strokeStyle=l[e],t.forEach(function(t){c.moveTo(t.x,t.y),c.lineTo(t.xt,t.yt),t.x=t.xt,t.y=t.yt}),c.stroke())}))}()}var u,m,p,y,_,f,v,g,w,M,x=S.minVelocity||0,C=S.maxVelocity||10,l=(S.velocityScale||.005)*(Math.pow(window.devicePixelRatio,1/3)||1),P=S.particleAge||90,b=S.lineWidth||1,D=S.particleMultiplier||1/300,T=Math.pow(window.devicePixelRatio,1/3)||1.6,e=S.frameRate||15,W=1e3/e,O=.97,R=S.colorScale||["rgb(36,104, 180)","rgb(60,157, 194)","rgb(128,205,193 )","rgb(151,218,168 )","rgb(198,231,181)","rgb(238,247,217)","rgb(255,238,159)","rgb(252,217,125)","rgb(255,182,100)","rgb(252,150,75)","rgb(250,112,52)","rgb(245,64,32)","rgb(237,45,28)","rgb(220,24,32)","rgb(180,0,35)"],h=[NaN,NaN,null],c=S.data,N=function(t,e){if(!m)return null;var n,i=z(t-y,360)/f,o=(_-e)/v,a=Math.floor(i),r=a+1,s=Math.floor(o),l=s+1;if(n=m[s]){var h=n[a],c=n[r];if(A(h)&&A(c)&&(n=m[l])){var d=n[a],p=n[r];if(A(d)&&A(p))return u.interpolate(i-a,o-s,h,c,d,p)}}return null},A=function(t){return null!=t},z=function(t,e){return t-e*Math.floor(t/e)},E=function(t,e,n,i,o){var a=2*Math.PI,r=e<0?5:-5,s=n<0?5:-5,l=V(n,e+r),h=V(n+s,e),c=Math.cos(n/360*a);return[(l[0]-i)/r/c,(l[1]-o)/r/c,(h[0]-i)/s,(h[1]-o)/s]},V=function(t,e,n){var i=S.map.latLngToContainerPoint(L.latLng(t,e));return[i.x,i.y]},U=function(){F.field&&F.field.release(),M&&cancelAnimationFrame(M)},F={params:S,start:function(e,n,i,t){var o={south:r(t[0][1]),north:r(t[1][1]),east:r(t[1][0]),west:r(t[0][0]),width:n,height:i};U(),function(t,e){var n=!0;t.length<2&&(n=!1),n||console.log("Windy Error: data must have at least two components (u,v)");var i=(u=d(t)).header;if(i.hasOwnProperty("gridDefinitionTemplate")&&0!=i.gridDefinitionTemplate&&(n=!1),n||console.log("Windy Error: Only data with Latitude_Longitude coordinates is supported"),n=!0,y=i.lo1,_=i.la1,f=i.dx,v=i.dy,g=i.nx,w=i.ny,i.hasOwnProperty("scanMode")){var o=i.scanMode.toString(2),a=(o=("0"+o).slice(-8)).split("").map(Number).map(Boolean);a[0]&&(f=-f),a[1]&&(v=-v),a[2]&&(n=!1),a[3]&&(n=!1),a[4]&&(n=!1),a[5]&&(n=!1),a[6]&&(n=!1),a[7]&&(n=!1),n||console.log("Windy Error: Data with scanMode: "+i.scanMode+" is not supported.")}(p=new Date(i.refTime)).setHours(p.getHours()+i.forecastTime),m=[];for(var r=0,s=360<=Math.floor(g*f),l=0;l<w;l++){for(var h=[],c=0;c<g;c++,r++)h[c]=u.data(r);s&&h.push(h[0]),m[l]=h}e({date:p,interpolate:N})}(c,function(t){!function(w,M,t,n){var x={},e=(t.south-t.north)*(t.west-t.east),C=l*Math.pow(e,.4),P=[],i=M.x;function o(t){for(var e,n,i,o,a,r,s,l,h,c,d,p,u,m=[],y=M.y;y<=M.yMax;y+=2){var _=(d=t,p=y,void 0,[(u=S.map.containerPointToLatLng(L.point(d,p))).lng,u.lat]),f=_[0],v=_[1];if(isFinite(f)){var g=w.interpolate(f,v);g&&(e=x,n=f,i=v,o=t,a=y,r=C,void 0,l=(s=g)[0]*r,h=s[1]*r,c=E(e,n,i,o,a),s[0]=c[0]*l+c[2]*h,s[1]=c[1]*l+c[3]*h,g=s,m[y+1]=m[y]=g)}}P[t+1]=P[t]=m}!function t(){for(var e=Date.now();i<M.width;)if(o(i),i+=2,1e3<Date.now()-e)return void setTimeout(t,25);a(P,M,n)}()}(t,function(t,e,n){var i=t[0],o=t[1],a=Math.round(i[0]),r=Math.max(Math.floor(i[1],0),0);Math.min(Math.ceil(o[0],e),e-1);return{x:a,y:r,xMax:e,yMax:Math.min(Math.ceil(o[1],n),n-1),width:e,height:n}}(e,n,i),o,function(t,e){F.field=e,s(t,e)})})},stop:U,createField:a,interpolatePoint:N,setData:function(t){c=t},setOptions:function(t){t.hasOwnProperty("minVelocity")&&(x=t.minVelocity),t.hasOwnProperty("maxVelocity")&&(C=t.maxVelocity),t.hasOwnProperty("velocityScale")&&(l=(t.velocityScale||.005)*(Math.pow(window.devicePixelRatio,1/3)||1)),t.hasOwnProperty("particleAge")&&(P=t.particleAge),t.hasOwnProperty("lineWidth")&&(b=t.lineWidth),t.hasOwnProperty("particleMultiplier")&&(D=t.particleMultiplier),t.hasOwnProperty("opacity")&&(O=+t.opacity),t.hasOwnProperty("frameRate")&&(e=t.frameRate),W=1e3/e}};return F};window.cancelAnimationFrame||(window.cancelAnimationFrame=function(t){clearTimeout(t)});