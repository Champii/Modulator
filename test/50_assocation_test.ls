_ = require 'underscore'
async = require 'async'
supertest = require 'supertest'
assert = require 'assert'

Nodulator = require '..'

Tests = null
Childs = null
News = null

test = it

describe 'Nodulator Associations', ->

  before (done) ->
    Nodulator.Reset ->
      Childs := Nodulator.Resource 'child'
      Childs.Create {field: 'child'}, (err, child) -> return console.error err if err?

      testConfig =
        schema:
          childId: 'int'
          child:
            type: Childs
            localKey: 'childId'

      Tests := Nodulator.Resource 'test', testConfig

      done!

  test 'should fetch child Resource', (done) ->
    blob =
      childId: 1

    Tests.Create blob, (err, test) ->
      throw new Error err if err?

      assert.equal test.child.field, 'child'

      done!

  test 'should create another resource with array of association', (done) ->
    err, res <- Childs.Create do
      field: 'child2'

    throw new Error err if err?

    newConfig =
      schema:
        childIds: ['int']
        children:
          type: [Childs]
          localKey: 'childIds'

    News := Nodulator.Resource 'new', newConfig

    done!

  test 'should fetch every child Resource', (done) ->
    blob =
      childIds: [1, 2]

    News.Create blob, (err, instance) ->
      throw new Error err if err?

      assert.equal instance.children.length, 2
      assert.equal instance.children[0].field, 'child'
      assert.equal instance.children[1].field, 'child2'

      done!

  test 'should fetch distantKey with array' (done) ->
    class Childs extends Nodulator.Resource 'child2', Nodulator.Route.MultiRoute

    testConfig =
      schema:
        child:
          type: Childs
          distantKey: 'testId'

    class Tests extends Nodulator.Resource 'test2', testConfig

    Childs.Create testId: 1 field: 'child'
    .fail -> throw new Error it
    .then -> Tests.Create test: \test
    .then ->
      assert.equal it.child.field, 'child'
      done!

  test 'should fetch distantKey with array of association' (done) ->
    Childs = Nodulator.Resource 'child3'

    testConfig =
      schema:
        children:
          type: [Childs]
          distantKey: 'testId'

    Tests = Nodulator.Resource 'test3', testConfig

    Childs.Create testId: 1 field: 'child'
    .fail -> throw new Error it
    .then -> Tests.Create test: \test
    .then ->
      assert.equal it.children.0.field, 'child'
      done!