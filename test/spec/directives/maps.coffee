describe 'Directives: GMap', ->

  # load the directive's module
  beforeEach module 'gmap'

  $compile = undefined
  scope = undefined

  # Initialize a mock scope
  beforeEach inject (_$compile_, $rootScope) ->
    $compile = _$compile_
    scope = $rootScope.$new()

  centerPos = new google.maps.LatLng(35.784, -78.670)
  
  createMap = (opts, attrs) ->
    defaultOpts =
      center: centerPos
      zoom: 15
      mapTypeId: 'roadmap'
    scope.mapOptions = angular.extend defaultOpts, (opts or {})
    elm = angular.element '<gmap-map/>'
    defaultAttrs =
      options: "mapOptions"
      widget: "myMap"
    attrs = angular.extend defaultAttrs, (attrs or {})
    for attributeName, value of attrs
      elm.attr attributeName, value
    $compile(elm)(scope)
    elm

  it 'should create an inner div for the map and move the class attribute to it', ->
    elm = createMap({}, {class: 'my_map'})
    expect(elm.children().eq(0).hasClass('my_map')).toBeTruthy()

  it 'should bind google map object to scope', ->
    createMap()
    expect(scope.myMap).toBeTruthy()

  it 'should create google map with given options', ->
    createMap(center: centerPos)
    expect(scope.myMap.getCenter()).toBe(centerPos)

  it 'should bind map tag properties to map properties', ->
    createMap({}, {zoom: 'zoom'})
    expect(scope.zoom).toBe(15)

  it 'should update map properties when bounded scope attributes change', ->
    createMap({}, {zoom: 'zoom'})
    scope.$apply -> scope.zoom = 12
    expect(scope.myMap.getZoom()).toBe(12)

  it 'should update scope attributes when bounded map properties change', ->
    createMap({}, {zoom: 'zoom'})
    scope.myMap.setZoom 18
    expect(scope.zoom).toBe(18)

  it 'should listen to events', ->
    createMap({}, {zoom_changed: 'zoomy = true'})
    google.maps.event.trigger scope.myMap, 'zoom_changed'
    expect(scope.zoomy).toBeTruthy()
