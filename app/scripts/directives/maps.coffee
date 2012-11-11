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
        scope.$apply ->
          getter(scope, $target: googleObject, $event: evt, $params:params)

bindMapAttributes = (scope, attrs, $parse, attributesStr, googleObject) ->
  for bindAttr in attributesStr.split(' ') when bindAttr of attrs
    do (bindAttr) ->
      gmGetterName = "get#{capitalize bindAttr}"
      gmSetterName = "set#{capitalize bindAttr}"
      gmEventName = "#{bindAttr.toLowerCase()}_changed"
      getter = $parse attrs[bindAttr]
      setter = getter.assign
      scope.$watch getter, (value) ->
        googleObject[gmSetterName] value
      if setter?
        google.maps.event.addListener googleObject, gmEventName, ->
          setter scope, googleObject[gmGetterName]()
          scope.$apply() unless scope.$$phase

class GMapMapController
  setMap: (@map) ->
  getMap: -> @map

app.directive 'gmapMap', ['$parse', ($parse) ->
  mapEvents = 'bounds_changed center_changed click dblclick drag dragend ' +
    'dragstart heading_changed idle maptypeid_changed mousemove mouseout ' +
    'mouseover projection_changed resize rightclick tilesloaded tilt_changed ' +
    'zoom_changed'
  mapAttributes = 'center zoom mapTypeId'
  controller: GMapMapController
  restrict: 'E'
  replace: true
  transclude: true
  template: '<div><div></div><div ng-transclude></div></div>'
  compile: (tElm, tAttrs) ->
    mapDiv = tElm.children().eq(0)
    for attr in ['class', 'id', 'style'] when attr of tAttrs
      mapDiv.attr attr, tAttrs[attr]
      tElm.removeAttr attr
    (scope, elm, attrs, controller) ->
      opts = angular.extend {}, scope.$eval(attrs.options)
      if attrs.widget
        widget = $parse attrs.widget
        map = widget scope
      map ?= new google.maps.Map elm.children()[0], opts
      widget.assign scope, map if attrs.widget
      controller.setMap map
      
      bindMapEvents scope, attrs, $parse, mapEvents, map
      bindMapAttributes scope, attrs, $parse, mapAttributes, map
]

app.directive 'gmapMarker', ['$parse', ($parse) ->
  events = 'animation_changed click clickable_changed cursor_changed ' +
    'dblclick drag dragend draggable_changed dragstart flat_changed icon_changed ' +
    'mousedown mouseout mouseover mouseup position_changed rightclick ' +
    'shadow_changed shape_changed title_changed visible_changed zindex_changed'
  attributes = 'animation clickable cursor draggable flat icon map position ' +
    'shadow shape title visible zIndex'
  require: '^?gmapMap'
  restrict: 'E'
  replace: true
  template: '<div></div>'
  link: (scope, elm, attrs, controller) ->
    if attrs.widget
      scopeWidget = $parse attrs.widget
      widget = scopeWidget scope
    widget ?= new google.maps.Marker {}
    scopeWidget.assign scope, widget if attrs.widget
    if controller
      map = controller.getMap()
      widget.setMap map
    
    bindMapEvents scope, attrs, $parse, events, widget
    bindMapAttributes scope, attrs, $parse, attributes, widget
]
