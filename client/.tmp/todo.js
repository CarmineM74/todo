(function() {
  var app;

  app = angular.module('app', []);

  app.constant('APP_CONFIG', {
    server: '127.0.0.1',
    port: '3000',
    version: '0.0.0'
  });

  angular.module('templates.coffee', []);

  angular.module('templates.common', []);

}).call(this);

//# sourceMappingURL=todo.js.map
