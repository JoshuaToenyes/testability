# ======= Test Dependencies =======

expect = (require 'chai').expect
assert = require 'assert'
testability = require './../dist/testability'



# ============= Tests =============

describe 'testability', ->

  beforeEach ->
    testability.restoreAll()


  it 'works without mocks', ->
    expect(require './fixtures/a').to.equal('abc')

  it 'works with global mocks are defined', ->
    testability.replace './b', 'x'
    testability.replace './c', 'y'
    expect(testability.require './fixtures/a').to.eql('axy')

  it 'works with mixed global mock and real modules', ->
    testability.replace './b', 'x'
    expect(testability.require './fixtures/a').to.eql('axc')

  it 'works with scoped mocks', ->
    t = testability.require './fixtures/a', {
      './b': 'yyy'
    }
    u = testability.require './fixtures/a'
    testability.replace './c', 'zzz'
    v = testability.require './fixtures/a', {
      './b': 'www'
    }
    expect(t).to.eql('ayyyc')
    expect(u).to.eql('abc')
    expect(v).to.eql('awwwzzz')

  it 'works with requires as mocks', ->
    testability.replace './b', require './fixtures/c'
    expect(testability.require './fixtures/a').to.eql('acc')


  describe '#load', ->
    
    it 'gives precedence to scoped mocks over global mocks', ->
      testability.replace './b', require './fixtures/c'
      t = testability.require './fixtures/a', {'./b': 'x'}
      expect(t).to.eql('axc')

    it 'works with whitespace, comma or bar separated scoped paths', ->
      t = testability.require './fixtures/a', {
        './not-real ./also-not/real,./b,|./c': 'x'}
      expect(t).to.eql('axx')
