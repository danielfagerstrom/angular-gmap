angular.module('angularGmapApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.currentMapCenter = new google.maps.LatLng(35.784, -78.670)
    $scope.zoom = 15

    $scope.locations = []
    $scope.addMarker = (evt) ->
      $scope.locations.push evt.latLng
    $scope.panTo = (location) ->
      $scope.currentMapCenter = location
    $scope.openMarkerInfo = (marker) ->
      console.log this, marker
      

    $scope.$watch 'myMap', (map)->
      console.log {map}