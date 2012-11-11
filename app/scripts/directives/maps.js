(function() {
  var app, bindMapAttributes, bindMapEvents, capitalize,
    __slice = [].slice;

  app = angular.module('gmap', []);

  capitalize = function(str) {
    return str[0].toUpperCase() + str.slice(1);
  };

  bindMapEvents = function(scope, attrs, $parse, eventsStr, googleObject) {
    var mapEvent, normalizedMapEvent, normalizedMapEvents, _i, _len, _results;
    normalizedMapEvents = (function() {
      var _i, _len, _ref, _results;
      _ref = eventsStr.split(' ');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        mapEvent = _ref[_i];
        _results.push(attrs.$normalize(mapEvent));
      }
      return _results;
    })();
    _results = [];
    for (_i = 0, _len = normalizedMapEvents.length; _i < _len; _i++) {
      normalizedMapEvent = normalizedMapEvents[_i];
      if (normalizedMapEvent in attrs) {
        _results.push((function(normalizedMapEvent) {
          var getter, gmEventName;
          gmEventName = attrs.$attr[normalizedMapEvent];
          getter = $parse(attrs[normalizedMapEvent]);
          return google.maps.event.addListener(googleObject, gmEventName, function() {
            var evt, params;
            evt = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
            return scope.$apply(function() {
              return getter(scope, {
                $event: evt,
                $params: params
              });
            });
          });
        })(normalizedMapEvent));
      }
    }
    return _results;
  };

  bindMapAttributes = function(scope, attrs, $parse, attributesStr, googleObject) {
    var bindAttr, _i, _len, _ref, _results;
    _ref = attributesStr.split(' ');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      bindAttr = _ref[_i];
      if (bindAttr in attrs) {
        _results.push((function(bindAttr) {
          var getter, gmEventName, gmGetterName, gmSetterName, setter;
          gmGetterName = "get" + (capitalize(bindAttr));
          gmSetterName = "set" + (capitalize(bindAttr));
          gmEventName = "" + (bindAttr.toLowerCase()) + "_changed";
          getter = $parse(attrs[bindAttr]);
          setter = getter.assign;
          scope.$watch(getter, function(value) {
            return googleObject[gmSetterName](value);
          });
          if (setter != null) {
            return google.maps.event.addListener(googleObject, gmEventName, function() {
              setter(scope, googleObject[gmGetterName]());
              if (!scope.$$phase) {
                return scope.$apply();
              }
            });
          }
        })(bindAttr));
      }
    }
    return _results;
  };

  app.directive('gmapMap', [
    '$parse', function($parse) {
      var mapAttributes, mapEvents;
      mapEvents = 'bounds_changed center_changed click dblclick drag dragend ' + 'dragstart heading_changed idle maptypeid_changed mousemove mouseout ' + 'mouseover projection_changed resize rightclick tilesloaded tilt_changed ' + 'zoom_changed';
      mapAttributes = 'center zoom mapTypeId';
      return {
        restrict: 'E',
        replace: true,
        template: '<div></div>',
        link: function(scope, elm, attrs) {
          var map, opts, widget;
          opts = angular.extend({}, scope.$eval(attrs.options));
          if (attrs.widget) {
            widget = $parse(attrs.widget);
            map = widget(scope);
          }
          if (map == null) {
            map = new google.maps.Map(elm[0], opts);
          }
          if (attrs.widget) {
            widget.assign(scope, map);
          }
          bindMapEvents(scope, attrs, $parse, mapEvents, map);
          return bindMapAttributes(scope, attrs, $parse, mapAttributes, map);
        }
      };
    }
  ]);

  app.directive('gmapMarker', [
    '$parse', function($parse) {
      var attributes, events;
      events = 'animation_changed click clickable_changed cursor_changed ' + 'dblclick drag dragend draggable_changed dragstart flat_changed icon_changed ' + 'mousedown mouseout mouseover mouseup position_changed rightclick ' + 'shadow_changed shape_changed title_changed visible_changed zindex_changed';
      attributes = 'animation clickable cursor draggable flat icon map position ' + 'shadow shape title visible zIndex';
      return {
        restrict: 'E',
        replace: true,
        template: '<div></div>',
        link: function(scope, elm, attrs) {
          var scopeWidget, widget;
          if (attrs.widget) {
            scopeWidget = $parse(attrs.widget);
            widget = scopeWidget(scope);
          }
          if (widget == null) {
            widget = new google.maps.Marker({});
          }
          if (attrs.widget) {
            scopeWidget.assign(scope, widget);
          }
          bindMapEvents(scope, attrs, $parse, events, widget);
          return bindMapAttributes(scope, attrs, $parse, attributes, widget);
        }
      };
    }
  ]);

}).call(this);
