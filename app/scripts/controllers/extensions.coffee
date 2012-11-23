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
    $scope.mStyleIcon = new StyledIcon(StyledIconTypes.BUBBLE, color: 'ffff00', text: "mText")
    $scope.mOpts = position: $scope.mLocation, styleIcon: $scope.mStyleIcon
    $scope.mStyleIcon2 = new StyledIcon(StyledIconTypes.MARKER, color: 'ff0000', text: "m")
    $scope.mOpts2 = (location) ->
      position: location, styleIcon: new StyledIcon(StyledIconTypes.MARKER, color: 'ff0000', text: "m")
    $scope.mText = "I'm a movable marker!"
