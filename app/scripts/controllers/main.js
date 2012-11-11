(function() {

  angular.module('angularGmapApp').controller('MainCtrl', function($scope) {
    $scope.currentMapCenter = new google.maps.LatLng(35.784, -78.670);
    $scope.zoom = 15;
    $scope.locations = [];
    $scope.addMarker = function(evt) {
      return $scope.locations.push(evt.latLng);
    };
    return $scope.panTo = function(location) {
      return $scope.currentMapCenter = location;
    };
  });

}).call(this);
