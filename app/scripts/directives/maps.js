(function() {
  var GMapMapController, app, bindMapAttributes, bindMapEvents, capitalize,
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
            getter(scope, {
              $target: googleObject,
              $event: evt,
              $params: params
            });
            if (!scope.$$phase) {
              return scope.$apply();
            }
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
        _results.push((function(bindAttr, loopLock) {
          var getter, gmEventName, gmGetterName, gmSetterName, setter;
          gmGetterName = "get" + (capitalize(bindAttr));
          gmSetterName = "set" + (capitalize(bindAttr));
          gmEventName = "" + (bindAttr.toLowerCase()) + "_changed";
          getter = $parse(attrs[bindAttr]);
          setter = getter.assign;
          scope.$watch(getter, function(value) {
            if (!loopLock) {
              try {
                loopLock = true;
                return googleObject[gmSetterName](value);
              } finally {
                loopLock = false;
              }
            }
          });
          if (setter != null) {
            return google.maps.event.addListener(googleObject, gmEventName, function() {
              if (!loopLock) {
                try {
                  loopLock = true;
                  setter(scope, googleObject[gmGetterName]());
                  if (!scope.$$phase) {
                    return scope.$apply();
                  }
                } finally {
                  loopLock = false;
                }
              }
            });
          }
        })(bindAttr, false));
      }
    }
    return _results;
  };

  GMapMapController = (function() {

    function GMapMapController() {}

    GMapMapController.prototype.setMap = function(map) {
      this.map = map;
    };

    GMapMapController.prototype.getMap = function() {
      return this.map;
    };

    return GMapMapController;

  })();

  app.directive('gmapMap', [
    '$parse', function($parse) {
      var attributes, events;
      events = 'bounds_changed center_changed click dblclick drag dragend ' + 'dragstart heading_changed idle maptypeid_changed mousemove mouseout ' + 'mouseover projection_changed resize rightclick tilesloaded tilt_changed ' + 'zoom_changed';
      attributes = 'center heading mapTypeId tilt zoom';
      return {
        controller: GMapMapController,
        restrict: 'E',
        compile: function(tElm, tAttrs) {
          var attr, mapDiv, _i, _len, _ref;
          mapDiv = angular.element('<div></div>');
          tElm.prepend(mapDiv);
          _ref = ['class', 'id', 'style'];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            attr = _ref[_i];
            if (!(attr in tAttrs)) {
              continue;
            }
            mapDiv.attr(attr, tAttrs[attr]);
            tElm.removeAttr(attr);
          }
          return function(scope, elm, attrs, controller) {
            var opts, scopeWidget, widget;
            opts = angular.extend({}, scope.$eval(attrs.options));
            if (attrs.widget) {
              scopeWidget = $parse(attrs.widget);
              widget = scopeWidget(scope);
            }
            if (widget == null) {
              widget = new google.maps.Map(elm.children()[0], opts);
            }
            if (attrs.widget) {
              scopeWidget.assign(scope, widget);
            }
            controller.setMap(widget);
            bindMapEvents(scope, attrs, $parse, events, widget);
            return bindMapAttributes(scope, attrs, $parse, attributes, widget);
          };
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
        require: '^?gmapMap',
        restrict: 'E',
        link: function(scope, elm, attrs, controller) {
          var map, opts, scopeWidget, widget;
          opts = angular.extend({}, scope.$eval(attrs.options));
          if (attrs.widget) {
            scopeWidget = $parse(attrs.widget);
            widget = scopeWidget(scope);
          }
          if (widget == null) {
            widget = new google.maps.Marker(opts);
          }
          if (attrs.widget) {
            scopeWidget.assign(scope, widget);
          }
          if (controller) {
            map = controller.getMap();
            widget.setMap(map);
          }
          bindMapEvents(scope, attrs, $parse, events, widget);
          return bindMapAttributes(scope, attrs, $parse, attributes, widget);
        }
      };
    }
  ]);

  app.directive('gmapInfoWindow', [
    '$parse', function($parse) {
      var attributes, events;
      events = 'closeclick content_change domready position_changed zindex_changed';
      attributes = 'content position zindex';
      return {
        restrict: 'E',
        link: function(scope, elm, attrs) {
          var opts, scopeWidget, widget, _open;
          elm.css('display', 'none');
          opts = angular.extend({}, scope.$eval(attrs.options));
          opts.content = elm.children()[0];
          if (attrs.widget) {
            scopeWidget = $parse(attrs.widget);
            widget = scopeWidget(scope);
          }
          if (widget == null) {
            widget = new google.maps.InfoWindow(opts);
          }
          if (attrs.widget) {
            scopeWidget.assign(scope, widget);
          }
          bindMapEvents(scope, attrs, $parse, events, widget);
          bindMapAttributes(scope, attrs, $parse, attributes, widget);
          _open = widget.open;
          return widget.open = function() {
            var args;
            args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            return _open.call.apply(_open, [widget].concat(__slice.call(args)));
          };
        }
      };
    }
  ]);

}).call(this);
