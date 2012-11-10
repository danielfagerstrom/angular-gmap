(function() {

  angular.module('angularGmapApp').controller('MainCtrl', function($scope) {
    $scope.mapOptions = {
      center: new google.maps.LatLng(35.784, -78.670),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      zoom: 16
    };
    $scope.zoom = 15;
    return $scope.addMarker = function(evt) {
      return console.log(JSON.stringify(evt.latLng));
    };
  });

}).call(this);
