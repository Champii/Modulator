_ = require 'underscore'
Nodulator = require '../'
Hacktiv = require 'hacktiv'

class ChangeWatcher

  func: null
  args: null
  res: {}

  @list: []

  constructor: (@func, @args) ->
    @dep = new Hacktiv.Dependency
    @doneIdx = @_FindDone()

    @args[@doneIdx] = @_WrapDoneFirst()

  _FindDone: ->
    for arg, i in @args
      if typeof(arg) is 'function'
        return i

    -1

  _WrapDoneFirst: ->
    @_oldDone = @args[@doneIdx]
    @args[@doneIdx] = (err, res) =>
      @res = res
      @_oldDone err, res
      @_ReWrap()

  _ReWrap: ->
    @args[@doneIdx] = (err, res) =>
      return console.error err if err?

      if (@res?.length? and res? and @res.length != res.length) or !_(@res).isEqual res
        @res = res
        @dep._Changed()

  Invalidate: ->
    @dep._Depends()
    @func @args...

  @Watch: (func, args) ->
    return false if not Nodulator.Watch.active or _(@list).find (item) -> item.func is func and _(item.args).isEqual args

    elem = new ChangeWatcher func, args
    @list.push elem
    elem.Invalidate()

  @Invalidate: =>
    for watcher in @list
      watcher.Invalidate()

module.exports = ChangeWatcher