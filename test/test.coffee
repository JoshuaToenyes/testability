# ======= Test Dependencies =======

expect = (require 'chai').expect
assert = require 'assert'
testability = require './../dist/testability'



# ============= Tests =============

describe 'testability', ->

  beforeEach ->
    testability.clear()


  it 'works without mocks', ->
    expect(require './fixtures/a').to.equal('abc')

  it 'works with global mocks are defined', ->
    testability.mock './b', 'x'
    testability.mock './c', 'y'
    expect(testability.load './fixtures/a').to.eql('axy')

  it 'works with mixed global mock and real modules', ->
    testability.mock './b', 'x'
    expect(testability.load './fixtures/a').to.eql('axc')

  it 'works with scoped mocks', ->
    t = testability.load './fixtures/a', {
      './b': 'yyy'
    }
    u = testability.load './fixtures/a'
    testability.mock './c', 'zzz'
    v = testability.load './fixtures/a', {
      './b': 'www'
    }
    expect(t).to.eql('ayyyc')
    expect(u).to.eql('abc')
    expect(v).to.eql('awwwzzz')

  it 'works with requires as mocks', ->
    testability.mock './b', require './fixtures/c'
    expect(testability.load './fixtures/a').to.eql('acc')


  describe '#load', ->
    
    it 'gives precedence to scoped mocks over global mocks', ->
      testability.mock './b', require './fixtures/c'
      t = testability.load './fixtures/a', {'./b': 'x'}
      expect(t).to.eql('axc')

    it 'works with whitespace, comma or bar separated scoped paths', ->
      t = testability.load './fixtures/a', {
        './not-real ./also-not/real,./b,|./c': 'x'}
      expect(t).to.eql('axx')
