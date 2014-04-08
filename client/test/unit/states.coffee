describe('States', ->

  beforeEach module('app')
  beforeEach module('templates.app')
  beforeEach module('templates.common')

  [$rootScope, $state, $injector, $httpBackend, $location] = ['','','','','']
  beforeEach(
    inject((_$rootScope_,_$state_,_$injector_,_$httpBackend_,_$location_) ->
              $rootScope = _$rootScope_
              $state = _$state_
              $injector = _$injector_
              $httpBackend = _$httpBackend_
              $location = _$location_
          )
  )

  describe('When state does not exist', ->

    called = false
    message = ''
    beforeEach(->
      $rootScope.$on('$stateNotFound', (ev, redirect, from, stateParams) =>
        expect(redirect.to).toEqual('really.unexisting.state')
        expect($state.current).toBe(from)
        called = true
      )

      try
        $state.go('really.unexisting.state')
        $rootScope.$digest()
      catch err
        message = err.message
    )

    it('should redirect broadcast $stateNotFound event', ->
      expect(called).toBeTruthy()
    )

    it('should redirect to home', ->
      expect($state.current.name).toBe('home')
    )

    it('should set location to /', ->
      expect($location.path()).toBe('/')
    )
  )

  describe('In home:', ->
    beforeEach(->
      $state.go('home')
      $rootScope.$digest()
    )

    afterEach( ->
      $httpBackend.verifyNoOutstandingExpectation()
      $httpBackend.verifyNoOutstandingRequest()
    )

    it('$state should be home', ->
      expect($state.current.name).toBe('home')
    )

    it('controller should be HomeController', ->
      expect($state.current.controller).toBe('HomeController')
    )

  )

)
