angular.module('angularGmapApp')
  .controller 'ExtensionsCtrl', ($scope) ->
    $scope.currentMapCenter = new google.maps.LatLng(35.784, -78.670)
    $scope.zoom = 15

    $scope.locations = []
    $scope.addMarker = (evt) ->
      $scope.locations.push evt.latLng
    $scope.panTo = (location) ->
      $scope.myMap.panTo location
    $scope.openMarkerInfo = (marker, location) ->
      $scope.currentMarkerLat = location.lat()
      $scope.currentMarkerLng = location.lng()
      $scope.myInfoWindow.open $scope.myMap, marker

    $scope.mLocation = new google.maps.LatLng(35.784, -78.670)
    $scope.mOptions =
      styleIcon: new StyledIcon(StyledIconTypes.BUBBLE, {color:"ff0000", text:"I'm a marker!"})
    $scope.$watch 'mLocation', -> console.log 'mLocation'
    $scope.myMarker = null
    $scope.$watch 'myMarker', (newVal, oldVal) -> console.log newVal, oldVal
    
