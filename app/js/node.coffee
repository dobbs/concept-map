class Node
  constructor: (@text) ->
  position: -> new Position(@x, @y)

@Node = Node