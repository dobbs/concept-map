positionMethods = 
  position: -> @

@createPosition = (x, y) ->
  _.extend Object.create(positionMethods),
    x: x
    y: y
