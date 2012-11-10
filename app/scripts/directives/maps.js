(function() {
  var app, capitalize,
    __slice = [].slice;

  app = angular.module('gmap', []);

  capitalize = function(str) {
    return str[0].toUpperCase() + str.slice(1);
  };

  app.directive('gmapMap', [
    '$parse', function($parse) {
      var mapEvents;
      mapEvents = 'bounds_changed center_changed click dblclick drag dragend ' + 'dragstart heading_changed idle maptypeid_changed mousemove mouseout ' + 'mouseover projection_changed resize rightclick tilesloaded tilt_changed ' + 'zoom_changed';
      return {
        restrict: 'E',
        replace: true,
        template: '<div></div>',
        link: function(scope, elm, attrs) {
          var bindAttr, map, mapEvent, normalizedMapEvent, normalizedMapEvents, opts, _i, _j, _len, _len1, _ref, _results;
          console.log(scope, attrs);
          normalizedMapEvents = (function() {
            var _i, _len, _ref, _results;
            _ref = mapEvents.split(' ');
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              mapEvent = _ref[_i];
              _results.push(attrs.$normalize(mapEvent));
            }
            return _results;
          })();
          opts = angular.extend({}, scope.$eval(attrs.options));
          map = new google.maps.Map(elm[0], opts);
          for (_i = 0, _len = normalizedMapEvents.length; _i < _len; _i++) {
            normalizedMapEvent = normalizedMapEvents[_i];
            if (normalizedMapEvent in attrs) {
              (function(normalizedMapEvent) {
                var getter, gmEventName;
                gmEventName = attrs.$attr[normalizedMapEvent];
                getter = $parse(attrs[normalizedMapEvent]);
                return google.maps.event.addListener(map, gmEventName, function() {
                  var evt, params;
                  evt = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
                  return scope.$apply(function() {
                    return getter(scope, {
                      $event: evt,
                      $params: params
                    });
                  });
                });
              })(normalizedMapEvent);
            }
          }
          _ref = ['center', 'zoom', 'mapTypeId'];
          _results = [];
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            bindAttr = _ref[_j];
            if (bindAttr in attrs) {
              _results.push((function(bindAttr) {
                var getter, gmEventName, gmGetterName, gmSetterName, setter;
                gmGetterName = "get" + (capitalize(bindAttr));
                gmSetterName = "set" + (capitalize(bindAttr));
                gmEventName = "" + (bindAttr.toLowerCase()) + "_changed";
                getter = $parse(attrs[bindAttr]);
                setter = getter.assign;
                scope.$watch(getter, function(value) {
                  return map[gmSetterName](value);
                });
                if (setter != null) {
                  return google.maps.event.addListener(map, gmEventName, function() {
                    setter(scope, map[gmGetterName]());
                    if (!scope.$$phase) {
                      return scope.$apply();
                    }
                  });
                }
              })(bindAttr));
            }
          }
          return _results;
        }
      };
    }
  ]);

}).call(this);
