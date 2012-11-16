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
    $scope.openMarkerInfo = function(marker, location) {
      $scope.currentMarkerLat = location.lat();
      $scope.currentMarkerLng = location.lng();
      return $scope.myInfoWindow.open($scope.myMap, marker);
    };
    $scope.mLocation = new google.maps.LatLng(35.784, -78.670);
    $scope.$watch('mLocation', function() {
      return console.log('mLocation');
    });
    $scope.myMarker = null;
    return $scope.$watch('myMarker', function(newVal, oldVal) {
      return console.log(newVal, oldVal);
    });
  });

}).call(this);
