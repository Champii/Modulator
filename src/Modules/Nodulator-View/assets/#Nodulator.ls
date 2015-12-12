rest = require 'rest'
async = require 'async'
mime = require('rest/interceptor/mime');

window import require \prelude-ls

Client = rest.wrap(mime)

class Nodulator

  isClient: true
  resources: {}

  Resource: (name, routes, config, _parent) ->
    return if config.abstract
    name = name + \s

    resource = _Resource name, config
    new routes resource

    N[capitalize name] = @resources[name] = resource

nodulator = new Nodulator

N = (...args) ->

  N.Resource.apply N, args

window.N = N <<<< nodulator

_Resource = (name, config) ->
  class Resource extends N.Wrappers

    (blob) ->
      if blob.promise?
        @_promise = blob.promise
        return @

      for k, v of blob
        if typeof! v is \Array
          blob[k] = map (-> new N[k] it), v

      import blob
      @


    _WrapReturnThis: (done) ->
      (arg) ~>
        res = done arg
        res?._promise || res || arg

    Then: ->
      @_promise = @_promise.then @_WrapReturnThis it if @_promise?
      @
    #
    Catch: ->
      @_promise = @_promise.catch @_WrapReturnThis it if @_promise?
      @

    Fail: ->
      @_promise = @_promise.fail @_WrapReturnThis it if @_promise?
      @

    Add: ->
    Save: @_WrapPromise @_WrapResolvePromise (done) ->
      # serie = @Serialize()


    Delete: @_WrapPromise @_WrapResolvePromise (done) ->


    @Create = @_WrapPromise @_WrapResolvePromise (blob = {}, done) ->
      resource = @
      if typeof! blob is \Function
        done = blob
        blob = {}
      Client method: \POST path: \/api/1/ + name + '/create', headers: {'Content-Type': 'application/json'}, entity: blob
        .then ~> done null new resource it.entity
        .catch done

    @List = @_WrapPromise @_WrapResolvePromise (blob = {}, done) ->
      resource = @
      if typeof! blob is \Function
        done = blob
        blob = {}

      Client method: \POST path: \/api/1/ + name + '/list', headers: {'Content-Type': 'application/json'}, entity: blob
        .then ~>
          async.mapSeries it.entity, (item, done) ->
            done null new resource item
          , done
        .catch done

    @Fetch = @_WrapPromise @_WrapResolvePromise (blob = {}, done) ->
      resource = @
      if typeof! blob is \Function
        done = blob
        blob = {}

      if typeof! blob is \Number
        blob = id: blob

      Client method: \POST path: \/api/1/ + name + '/fetch', headers: {'Content-Type': 'application/json'}, entity: blob
        .then ~> done null new resource it.entity
        .catch done

    @Field = ->
      Default: ->
    @MayHasMany = ->
    @Init = ->