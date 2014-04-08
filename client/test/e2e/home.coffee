describe('E2E: Home page', ->
  fail = -> expect(true).toBe(false)

  it('should have a navigation header', ->
    browser.get('#/')
    ele = element(By.id('navigationHeader'))
    expect(ele.isPresent()).toBe(true)
  )

  it('should have a welcome message',fail)
  it('should have a login widget',fail)
  it('should have a signup link',fail)
)
