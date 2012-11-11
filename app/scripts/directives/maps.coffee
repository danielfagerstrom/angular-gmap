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
          getter(scope, $event: evt, $params:params)

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

app.directive 'gmapMap', ['$parse', ($parse) ->
  mapEvents = 'bounds_changed center_changed click dblclick drag dragend ' +
    'dragstart heading_changed idle maptypeid_changed mousemove mouseout ' +
    'mouseover projection_changed resize rightclick tilesloaded tilt_changed ' +
    'zoom_changed'
  mapAttributes = 'center zoom mapTypeId'
  restrict: 'E'
  replace: true
  template: '<div></div>'
  link: (scope, elm, attrs) ->
    console.log scope, attrs
    opts = angular.extend {}, scope.$eval(attrs.options)
    if attrs.widget
      widget = $parse attrs.widget
      map = widget scope
    map ?= new google.maps.Map elm[0], opts
    widget.assign scope, map if attrs.widget
    
    bindMapEvents scope, attrs, $parse, mapEvents, map
    bindMapAttributes scope, attrs, $parse, mapAttributes, map
]
