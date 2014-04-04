describe('States', ->
  [$rootScope, $state, $injector, $httpBackend] = ['','','','']

  beforeEach(-> module('app'))
  beforeEach(-> module('templates'))
  beforeEach(->
    inject((_$rootScope_,_$state_,_$injector_, _$httpBackend_) ->
      $rootScope = _$rootScope_
      $state = _$state_
      $injector = _$injector_
      $httpBackend = _$httpBackend_
    )
  )

  describe('State: visitor', ->
    beforeEach(-> $state.go('visitor'))
    it('$state should be visitor', ->
      expect($state.current.name).toBe('visitor')
    )
  )
)
