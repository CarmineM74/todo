app = angular.module('app',[
  'ui.router'
  ,'templates.app'
  ,'templates.common'
])

app.constant('APP_CONFIG', {
  server: '127.0.0.1'
  ,port: '3000'
  ,version: '0.0.0'
})

app.config(($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise("/home")

  $stateProvider
    .state('home', {
      ,url: '/home'
      templateUrl: 'home.tpl.html'
    })
)



