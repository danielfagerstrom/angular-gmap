describe 'Controller: MainCtrl', () ->

  # load the controller's module
  beforeEach module 'angularGmapApp'

  MainCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope = {$watch: ->}
    MainCtrl = $controller 'MainCtrl', {
      $scope: scope
    }

  it 'should attach a value to zoom', () ->
    expect(scope.zoom).toBe 15
