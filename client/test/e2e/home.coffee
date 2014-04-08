describe('E2E: Home page', ->

  it('should have a navigation header', ->
    browser.get('#/')
    ele = element(By.id('navigationHeader'))
    expect(ele.isPresent()).toBe(true)
  )
)
