angular.module('angularGmapApp')
  .controller 'ExtensionsCtrl', ($scope, $log) ->
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
    $scope.mText = "I'm a movable marker!"
    $scope.$watch 'mLocation', -> $log.log 'mLocation'
    $scope.myMarker = null
    $scope.$watch 'myMarker', (newVal, oldVal) -> $log.log newVal, oldVal
    $scope.textChange = -> $log.log 'text_change'
    
