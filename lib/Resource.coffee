_ = require 'underscore'
async = require 'async'

table = require('./connectors/sql').table

excludedMembers = [
  'table'
  'app'
  'resName']

module.exports = ->

  class Resource

    table: null
    app: null
    resName: null

    constructor: (blob) ->
      for key, value of blob
        @[key] = value

    Save: (done) ->
      exists = @id?

      @table.Save @Serialize(), (err, id) =>
        return done err if err?

        if !exists
          @id = id

        done null, @

    Serialize: ->
      res = {}
      for key, value of @ when typeof value isnt 'function' and key not in excludedMembers
        res[key] = value
      res

    ToJSON: ->
      @Serialize()

    @Route: (type, url, done) ->
      @app[type] '/api/1/' + @resName + url, done

    @Fetch: (id, done) ->
      @table.Find id, (err, blob) =>
        return done err if err?

        @Deserialize blob, done

    @List: (done) ->
      @table.Select 'id', {}, {}, (err, ids) =>
        return done err if err?

        async.map _(ids).pluck('id'), (item, done) =>
          @Fetch item, done
        , done

    @Deserialize: (blob, done) ->
      res = new @ blob
      res.table = @table
      res.resName = @resName
      res.app = @app
      done null, res

    @SetHelpers: (resName, app) ->
      @table = table resName
      @resName = resName
      @app = app

