'use strict'

angular.module('angularGmapApp', ['gmap'])
  .config ['$routeProvider', ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/extensions',
        templateUrl: 'views/extensions.html'
        controller: 'ExtensionsCtrl'
      .otherwise
        redirectTo: '/'
  ]
