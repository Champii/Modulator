Modulator
============

  Set of class for CoffeeScript to create tiny API easely

  Tends to be a easy to use library, with basic auth system (Passport) and classic DB systems (Mysql/Mongo/RAM)

  (Can be used in Javascript, obviously, but not tested yet)

  Based on:

    async
    express
    underscore
    mysql
    mongous
    body-parser
    cookie-parser
    passport
    passport-local
    express-session
    mocha
    assert
    superagent
    supertest


#Usage#

  Requirement:

    Modulator = require './lib/Modulator'

  Resource declaration is easy.

    APlayer = Modulator.Resource 'player'

  It create automaticaly a Document (for Mongo or SqlMem)

  No fixed fields, excepted for Mysql: you have to follow thefields you have defined in your database

  It create also default routes

    GET     /api/1/players       => List
    GET     /api/1/players/:id   => Get One
    POST    /api/1/players       => Create
    PUT     /api/1/players/:id   => Update
    DELETE  /api/1/players/:id   => Delete

  It include 6 methods

    *Fetch(id, done)
    *List(done)
    *Deserialize(blob, done)
    Save(done)
    Delete(done)
    Serialize()
    ToJSON()

    * Class methods

  You can now extends the resource

    class PlayerResource extends APlayer

      constructor: (blob) ->    # Optional
        super blob              #

      LevelUp: (done) ->
        @level++
        @Save done

  (Here we have a custom method: LevelUp)

  You can define custom routes:

    PlayerResource.Route 'put', '/:id/levelUp', (req, res) ->
      PlayerResource.Fetch req.params.id, (err, player) ->
        return res.send 500 if err?

        player.LevelUp (err) ->
          return res.send 500 if err?

          res.send 200, player.ToJSON()

  It define :

    PUT     /api/1/players/:id/levelUp

  Open exemple.coffee to see a better exemple

#Config#

  Config system actualy permit to switch betwin InRAM Document system (Default value, no persistant data), Mysql and Mongo.

  You have to call Config method only once, and before declaring any resources.

    Modulator.Config
      dbType: 'Mongo'         # You can select 'SqlMem' to use inRAM Document (no persistant data, used to test) or 'Mongo' or 'Mysql'
      dbAuth:
        host: 'localhost'
        database: 'test'
        # port: 27017         # Can be ignored, default values taken
        # user: 'test'        # For Mongo, these fields are optionals
        # pass: 'test'        #

  If you omit to call Config, it will takes default value (dbType: 'SqlMem')

#Auth#

  Authentication is based on Passport

  You can assign a Ressource as AccountResource :

    APlayer = Modulator.Resource 'player',
      account: true

  Defaults fields are 'username' and 'password'

  You can change them :

    APlayer = Modulator.Resource 'player',
      account:
        fields:
          usernameField: "login"
          passwordField: "pass"

  It creates a custom method from usernameField

    *FetchByUsername(username, done)

      or if customized

    *FetchByLogin(login, done)

    * Class methods

    /!\ WARNING BUG /!\
    Theses methods return Resource object instead of extended object

  It defines 2 routes :

    POST    /api/1/players/login
    POST    /api/1/players/logout

  It setup session system, and thanks to Passport,

  it fills req.user variable to handle public/authenticated routes


#To Do#

  By order of priority

    Override default routes
    Test suite
    Error management
    Better routing system (Auto add on custom method ?)
    General architecture and file generation
    Advanced Auth (Social + custom)
    Basic view system
    Relational models
