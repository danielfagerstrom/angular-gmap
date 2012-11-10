app = angular.module 'gmap', []

capitalize = (str) ->
  str[0].toUpperCase() + str[1...]

app.directive 'gmapMap', ['$parse', ($parse) ->
  mapEvents = 'bounds_changed center_changed click dblclick drag dragend ' +
    'dragstart heading_changed idle maptypeid_changed mousemove mouseout ' +
    'mouseover projection_changed resize rightclick tilesloaded tilt_changed ' +
    'zoom_changed'
  restrict: 'E'
  replace: true
  template: '<div></div>'
  link: (scope, elm, attrs) ->
    console.log scope, attrs
    normalizedMapEvents = (attrs.$normalize(mapEvent) for mapEvent in mapEvents.split(' '))
    opts = angular.extend {}, scope.$eval(attrs.options)
    map = new google.maps.Map elm[0], opts
    for normalizedMapEvent in normalizedMapEvents when normalizedMapEvent of attrs
      do (normalizedMapEvent) ->
        gmEventName = attrs.$attr[normalizedMapEvent]
        getter = $parse attrs[normalizedMapEvent]
        google.maps.event.addListener map, gmEventName, (evt, params...) ->
          scope.$apply ->
            getter(scope, $event: evt, $params:params)
    for bindAttr in ['center', 'zoom', 'mapTypeId'] when bindAttr of attrs
      do (bindAttr) ->
        gmGetterName = "get#{capitalize bindAttr}"
        gmSetterName = "set#{capitalize bindAttr}"
        gmEventName = "#{bindAttr.toLowerCase()}_changed"
        getter = $parse attrs[bindAttr]
        setter = getter.assign
        scope.$watch getter, (value) ->
          map[gmSetterName] value
        if setter?
          google.maps.event.addListener map, gmEventName, ->
            setter scope, map[gmGetterName]()
            scope.$apply() unless scope.$$phase
]