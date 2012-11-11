angular.module('angularGmapApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.currentMapCenter = new google.maps.LatLng(35.784, -78.670)
    $scope.zoom = 15

    $scope.locations = []
    $scope.addMarker = (evt) ->
      $scope.locations.push evt.latLng
    $scope.panTo = (location) ->
      $scope.myMap.panTo location
    $scope.openMarkerInfo = (marker) ->
      $scope.currentMarkerLat = marker.getPosition().lat()
      $scope.currentMarkerLng = marker.getPosition().lng()
      $scope.myInfoWindow.open $scope.myMap, marker
