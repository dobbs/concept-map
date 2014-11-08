positionPrototype = 
  position: -> @

@createPosition = (x, y) ->
  position = Object.create positionPrototype
  _.extend position,
    x: x
    y: y
