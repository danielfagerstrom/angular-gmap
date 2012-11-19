app = angular.module 'gmap', []

capitalize = (str) ->
  str[0].toUpperCase() + str[1...]

bindMapEvents = (scope, attrs, $parse, eventsStr, googleObject) ->
  normalizedMapEvents = (attrs.$normalize(mapEvent) for mapEvent in eventsStr.split(' '))
  for normalizedMapEvent in normalizedMapEvents when normalizedMapEvent of attrs
    do (normalizedMapEvent) ->
      gmEventName = attrs.$attr[normalizedMapEvent]
      getter = $parse attrs[normalizedMapEvent]
      google.maps.event.addListener googleObject, gmEventName, (evt, params...) ->
        getter(scope, $target: googleObject, $event: evt, $params:params)
        scope.$apply() unless scope.$$phase

bindMapProperties = (scope, attrs, $parse, propertiesStr, googleObject) ->
  for bindProp in propertiesStr.split(' ') when bindProp of attrs
    do (bindProp, loopLock=false) ->
      locked = (fn) ->
        unless loopLock
          try
            loopLock = true
            fn()
          finally
            loopLock = false
      gmGetterName = "get#{capitalize bindProp}"
      gmSetterName = "set#{capitalize bindProp}"
      gmEventName = "#{bindProp.toLowerCase()}_changed"
      getter = $parse attrs[bindProp]
      setter = getter.assign
      scope.$watch getter, (value) ->
        locked ->
          googleObject[gmSetterName] value
      if setter?
        unless getter scope
          locked ->
            setter scope, googleObject[gmGetterName]()
            scope.$digest() unless scope.$$phase
        google.maps.event.addListener googleObject, gmEventName, ->
          locked ->
            setter scope, googleObject[gmGetterName]()
            scope.$digest() unless scope.$$phase

getMapFromController = (scope, attrs, $parse, controller, widget) ->
  if controller
    controller.getMap().then (map) ->
      widget.setMap map
      if attrs.map
        mapAttr = $parse attrs.map
        if mapAttr.setter
          scope.$apply ->
            mapAttr.setter scope, map

class GMapMapController
  constructor: ($q) ->
    @map = $q.defer()
  setMap: (map) ->
    @map.resolve map
  getMap: ->
    @map.promise

GMapMapController.$inject = ['$q']

app.directive 'gmapMap', ['$parse', ($parse) ->
  events = 'bounds_changed center_changed click dblclick drag dragend ' +
    'dragstart heading_changed idle maptypeid_changed mousemove mouseout ' +
    'mouseover projection_changed resize rightclick tilesloaded tilt_changed ' +
    'zoom_changed'
  properties = 'center heading mapTypeId tilt zoom'
  controller: GMapMapController
  restrict: 'E'
  compile: (tElm, tAttrs) ->
    mapDiv = angular.element '<div></div>'
    tElm.prepend mapDiv
    for attr in ['class', 'id', 'style'] when attr of tAttrs
      mapDiv.attr attr, tAttrs[attr]
      tElm.removeAttr attr
    (scope, elm, attrs, controller) ->
      opts = angular.extend {}, scope.$eval(attrs.options)
      if attrs.widget
        scopeWidget = $parse attrs.widget
        widget = scopeWidget scope
      widget ?= new google.maps.Map elm.children()[0], opts
      scopeWidget.assign scope, widget if attrs.widget
      controller.setMap widget
      
      bindMapEvents scope, attrs, $parse, events, widget
      bindMapProperties scope, attrs, $parse, properties, widget
]

app.directive 'gmapMarker', ['$parse', ($parse) ->
  events = 'animation_changed click clickable_changed cursor_changed ' +
    'dblclick drag dragend draggable_changed dragstart flat_changed icon_changed ' +
    'mousedown mouseout mouseover mouseup position_changed rightclick ' +
    'shadow_changed shape_changed title_changed visible_changed zindex_changed'
  properties = 'animation clickable cursor draggable flat icon map position ' +
    'shadow shape title visible zIndex'
  require: '^?gmapMap'
  restrict: 'E'
  link: (scope, elm, attrs, controller) ->
    opts = angular.extend {}, scope.$eval(attrs.options)
    if attrs.widget
      scopeWidget = $parse attrs.widget
      widget = scopeWidget scope
    widget ?= new google.maps.Marker opts
    scopeWidget.assign scope, widget if attrs.widget
    getMapFromController scope, attrs, $parse, controller, widget

    bindMapEvents scope, attrs, $parse, events, widget
    bindMapProperties scope, attrs, $parse, properties, widget
]

app.directive 'gmapInfoWindow', ['$parse', ($parse) ->
  events = 'closeclick content_change domready position_changed zindex_changed'
  properties = 'content position zindex'
  restrict: 'E'
  link: (scope, elm, attrs) ->
    elm.css 'display', 'none'
    opts = angular.extend {}, scope.$eval(attrs.options)
    opts.content = elm.children()[0]
    if attrs.widget
      scopeWidget = $parse attrs.widget
      widget = scopeWidget scope
    widget ?= new google.maps.InfoWindow opts
    scopeWidget.assign scope, widget if attrs.widget
    
    bindMapEvents scope, attrs, $parse, events, widget
    bindMapProperties scope, attrs, $parse, properties, widget

    _open = widget.open
    widget.open = (args...) ->
      _open.call widget, args...
]
