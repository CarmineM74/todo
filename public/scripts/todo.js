(function() {
  var app;

  app = angular.module('app', ['ui.router', 'templates.app', 'templates.common', 'home']);

  app.constant('APP_CONFIG', {
    server: '127.0.0.1',
    port: '3000',
    version: '0.0.0'
  });

  app.config(function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/");
    return $stateProvider.state('home', {
      url: '/',
      templateUrl: 'home.tpl.html',
      controller: 'HomeController'
    });
  });

  angular.module('home', []).controller('HomeController', function($scope) {});

  angular.module('templates.app', ['home.tpl.html']);

  angular.module("home.tpl.html", []).run([
    "$templateCache", function($templateCache) {
      return $templateCache.put("home.tpl.html", "<h1>Hello world!</h1>\n" + "\n" + "");
    }
  ]);

  angular.module('templates.common', []);

}).call(this);

//# sourceMappingURL=todo.js.map
