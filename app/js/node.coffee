class Node
  constructor: (@text='', @x=undefined, @y=undefined) ->
  position: -> new Position(@x, @y)

@Node = Node