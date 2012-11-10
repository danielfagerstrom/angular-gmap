angular.module('angularGmapApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.mapOptions =
      center: new google.maps.LatLng(35.784, -78.670)
      mapTypeId: google.maps.MapTypeId.ROADMAP
      zoom: 16

    $scope.zoom = 15

    $scope.addMarker = (evt) ->
      console.log JSON.stringify evt.latLng