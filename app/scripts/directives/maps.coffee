app = angular.module 'gmap', []

capitalize = (str) ->
  str[0].toUpperCase() + str[1...]

class Helper
  constructor: (@$parse, @scope, @elm, @attrs, @controller) ->
    
  bindMapEvents: (eventsStr, googleObject) ->
    normalizedMapEvents = (@attrs.$normalize(mapEvent) for mapEvent in eventsStr.split(' '))
    for normalizedMapEvent in normalizedMapEvents when normalizedMapEvent of @attrs
      do (normalizedMapEvent) =>
        gmEventName = @attrs.$attr[normalizedMapEvent]
        getter = @$parse @attrs[normalizedMapEvent]
        google.maps.event.addListener googleObject, gmEventName, (evt, params...) =>
          getter(@scope, $target: googleObject, $event: evt, $params: params)
          @scope.$apply() unless @scope.$$phase

  bindMapProperties: (propertiesStr, googleObject) ->
    for bindProp in propertiesStr.split(' ') when bindProp of @attrs
      do (bindProp, loopLock=false) =>
        locked = (fn) ->
          unless loopLock
            try
              loopLock = true
              fn()
            finally
              loopLock = false
        gmGet = (googleObject, propName) ->
          gmGetterName = "get#{capitalize propName}"
          if googleObject[gmGetterName]
            googleObject[gmGetterName]()
          else
            googleObject.get propName
        gmSet = (googleObject, propName, value) ->
          gmSetterName = "set#{capitalize propName}"
          if googleObject[gmSetterName]
            googleObject[gmSetterName] value
          else
            googleObject.set propName, value
        gmEventName = "#{bindProp.toLowerCase()}_changed"
        getter = @$parse @attrs[bindProp]
        setter = getter.assign
        @scope.$watch getter, (value) ->
          locked ->
            gmSet googleObject, bindProp, value
        if setter?
          unless getter @scope
            locked =>
              setter @scope, gmGet(googleObject, bindProp)
              @scope.$digest() unless @scope.$$phase
          google.maps.event.addListener googleObject, gmEventName, =>
            locked =>
              setter @scope, gmGet(googleObject, bindProp)
              @scope.$digest() unless @scope.$$phase

  getOpts: ->
    angular.extend {}, @scope.$eval(@attrs.options)

  getMapFromController: (widget) ->
    if @controller
      @controller.getMap().then (map) =>
        widget.setMap map
        if @attrs.map
          mapAttr = @$parse @attrs.map
          if mapAttr.setter
            @scope.$apply ->
              mapAttr.setter @scope, map

  getAttrValue: (attrName) ->
    if @attrs[attrName]
      value = @$parse(@attrs[attrName])(@scope)
    value

  setAttrValue: (attrName, value) ->
    if @attrs[attrName]
      @$parse(@attrs[attrName]).assign @scope, value

  createOrGetAttrValue: (attrName, factoryFn) ->
    value = @getAttrValue attrName
    value ?= factoryFn()
    @setAttrValue attrName, value
    value

  createOrGetWidget: (factoryFn) ->
    @createOrGetAttrValue 'widget', factoryFn

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
      h = new Helper $parse, scope, elm, attrs, controller
      opts = h.getOpts()
      widget = h.createOrGetWidget ->
        new google.maps.Map elm.children()[0], opts
      controller.setMap widget
      
      h.bindMapEvents events, widget
      h.bindMapProperties properties, widget
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
    h = new Helper $parse, scope, elm, attrs, controller
    opts = h.getOpts()
    widget = h.createOrGetWidget ->
      new google.maps.Marker opts
    h.getMapFromController widget

    h.bindMapEvents events, widget
    h.bindMapProperties properties, widget
]

app.directive 'gmapInfoWindow', ['$parse', ($parse) ->
  events = 'closeclick content_change domready position_changed zindex_changed'
  properties = 'content position zindex'
  restrict: 'E'
  link: (scope, elm, attrs) ->
    h = new Helper $parse, scope, elm, attrs
    elm.css 'display', 'none'
    opts = h.getOpts()
    opts.content = elm.children()[0]
    widget = h.createOrGetWidget ->
      new google.maps.InfoWindow opts
    
    h.bindMapEvents events, widget
    h.bindMapProperties properties, widget

    _open = widget.open
    widget.open = (args...) ->
      _open.call widget, args...
]

app.directive 'gmapStyledMarker', ['$parse', ($parse) ->
  events = 'animation_changed click clickable_changed cursor_changed ' +
    'dblclick drag dragend draggable_changed dragstart flat_changed icon_changed ' +
    'mousedown mouseout mouseover mouseup position_changed rightclick ' +
    'shadow_changed shape_changed title_changed visible_changed zindex_changed'
  properties = 'animation clickable cursor draggable flat icon map position ' +
    'shadow shape title visible zIndex'
  styleEvents = 'text_changed color_changed fore_changed starcolor_changed'
  styleProperties = 'text color fore starcolor'
  require: '^?gmapMap'
  restrict: 'E'
  link: (scope, elm, attrs, controller) ->
    h = new Helper $parse, scope, elm, attrs, controller
    opts = h.getOpts()
    
    styledIconTypeName = (h.getAttrValue('iconType') or 'marker').toUpperCase()
    opts.styleIcon = h.createOrGetAttrValue 'styleIcon', ->
      opts.styleIcon or new StyledIcon(StyledIconTypes[styledIconTypeName], {})
    h.bindMapEvents styleEvents, opts.styleIcon
    h.bindMapProperties styleProperties, opts.styleIcon

    widget = h.createOrGetWidget ->
      new StyledMarker opts
    h.getMapFromController widget

    h.bindMapEvents events, widget
    h.bindMapProperties properties, widget
]

