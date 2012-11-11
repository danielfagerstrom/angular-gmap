(function() {

  angular.module('angularGmapApp').controller('MainCtrl', function($scope) {
    $scope.currentMapCenter = new google.maps.LatLng(35.784, -78.670);
    $scope.zoom = 15;
    $scope.locations = [];
    $scope.addMarker = function(evt) {
      return $scope.locations.push(evt.latLng);
    };
    $scope.panTo = function(location) {
      return $scope.myMap.panTo(location);
    };
    return $scope.openMarkerInfo = function(marker) {
      $scope.currentMarkerLat = marker.getPosition().lat();
      $scope.currentMarkerLng = marker.getPosition().lng();
      return $scope.myInfoWindow.open($scope.myMap, marker);
    };
  });

}).call(this);
