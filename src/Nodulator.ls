require! {
  underscore: _
  fs
  path
  hacktiv
  \prelude-ls : {each, obj-to-pairs}
  \./Helpers/Debug
  \./Resource/Connectors : DB
}

debug-nodulator = new Debug 'N::Core'

class N

  resources: {}
  config: null
  consoleMode: false
  defaultConfig:
    db: type: \SqlMem
    cache: false
    flipDone: false

  ->
    @Init()

  Init: ->

    debug-nodulator.Log \Init

    @appRoot = path.resolve \.


    debug-nodulator.Log 'Init ended'

  Resource: (name, routes, config, _parent) ->

    getParentChain = ->
      | it?._parent? => " <= #{that.name}" + getParentChain that
      | _   => ''

    debug-nodulator.Log "Start creating resource: #{name + getParentChain @resources[name]}"

    resource = null
    name = name.toLowerCase()
    if @resources[name]?
      debug-nodulator.Log "Existing resource : #{name}"
      return @resources[name]

    if routes? and not routes.prototype
      config = routes
      routes = null

    @Config() # config of N instance, not resource one

    if config?
      config.db = {} if not config.db?

      obj-to-pairs @config.db |> each ->
        | not config.db[it.0]? => config.db[it.0] = it.1

    config = @config if not config?

    if _parent?
      class ExtendedResource extends _parent

      table = new DB name + \s
      if config?.db?.type or config?.db?.host? or config?.db?.user? or config?.db?.port? and not config?.abstract
        table.AddDriver config
      else if not config? or (config? and not config.abstract)
        table.AddDriver @config
      @resources[name] = resource := ExtendedResource
      @resources[name]._PrepareResource table, config, @app, routes, name, _parent
    else
      table = new DB name + \s
      if not config?.abstract
        table.AddDriver config
      else if not config? or (config? and not config.abstract)
        table.AddDriver @config

      @resources[name] = resource :=
        require(\./Resource/Resource) table, config, @app, routes, name

    debug-nodulator.Log "Resource added : #{name + getParentChain @resources[name]}"

    resource

  Route: require \./Route/Route

  Config: (config) ->
    if @config?
      debug-nodulator.Warn "Aleady configured"
      return

    debug-nodulator.Warn "Start main config"

    @config = config || @defaultConfig

    @defaultConfig
      |> obj-to-pairs
      |> each ~> @config[it.0] = it.1 if not @config[it.0]?


  Use: (module) ->
    debug-nodulator.Log "Loading module"
    m = module @
    debug-nodulator.Log "Loaded module: #{m.name}"
    m

  Console: (@consoleMode = true) ->

  ExtendDefaultConfig: (config) ->
    @defaultConfig = _(@defaultConfig).extend config

  Bus: require \./Helpers/Bus
  bus: new @::Bus()

  Watch:    Hacktiv
  DontWatch: Hacktiv.DontWatch

  Reset: (done) ->
    debug-nodulator.Warn "Reset"

    cache = require \./Resource/Cache
    if cache.client?
      cache.Reset!
    require \./Resource/Wrappers .Reset!

    @inited = {}
    DB.Reset!
    @resources = {}
    @config = null

    if @server?
      @app = null
      @server.close()
      @server = null


    @Init()

    done() if done?

  _ListEndpoints: (done) ->
    endpoints = []
    for endpoint in @app._router.stack
      if endpoint.route?
        res = {}
        res[endpoint.route.path] = [key for key of endpoint.route.methods]
        endpoints.push res
    done(endpoints) if done?

Nodulator = new N

f = (...args) ->

  f.Config! if not f.config?
  f.Resource.apply f, args

f = f <<<< Nodulator

module.exports = f
