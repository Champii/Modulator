require! {\.. : {{Collection}:Route}:N}

class WeaponRoute extends Route
  Config: ->
    @Get ~> @resource.List!

Weapon = N \weapons WeaponRoute, schema: \strict
  ..Field \power \int .Default 10

class Unit extends N \unit abstract: true schema: \strict
  LevelUp:           -> @Set (.level++)
  Attack: (targetId) ->
    throw 'No weapon' if not @Weapon?
    Target = switch @_type
      | \player => Monster
      | \monster => Player
    Target.Fetch targetId .Set ~> it.life -= @Weapon.power

Unit
  ..Field \level \int  .Default 1
  ..Field \life  \int  .Default 100
  ..MayBelongsTo Weapon

class UnitRoute extends Collection
  Config: ->
    super!
    @Put \/:id/levelup          (.instance.LevelUp!)
    @Put \/:id/attack/:targetId (.instance.Attack +it.params.targetId)

Player =  Unit.Extend \players  UnitRoute
Monster = Unit.Extend \monsters UnitRoute

# Exemple seed:
Player
  .Create!
  .Add Weapon.Create power: 25

Monster
  .Create!
  .Add Weapon.Create!

# Created routes :
#  - GET    /api/1/players                       => Get all players
#  - GET    /api/1/players/:id                   => Get player with given id
#  - POST   /api/1/players                       => Create a player
#  - PUT    /api/1/players/:id                   => Modify the player with given id
#  - DELETE /api/1/players/:id                   => Delete the given player
#  - PUT    /api/1/players/:id/levelup           => LevelUp the given player
#  - PUT    /api/1/players/:id/attack/:targetId  => Attack the given monster
#
#  - GET    /api/1/monsters                      => Get all monsters
#  - GET    /api/1/monsters/:id                  => Get monster with given id
#  - POST   /api/1/monsters                      => Create a monster
#  - PUT    /api/1/monsters/:id                  => Modify the monster with given id
#  - DELETE /api/1/monsters/:id                  => Delete the given monster
#  - PUT    /api/1/monsters/:id/levelup          => LevelUp the given monster
#  - PUT    /api/1/monsters/:id/attack/:targetId => Attack the given player
#
#  - GET    /api/1/weapons                       => Get all weapons
