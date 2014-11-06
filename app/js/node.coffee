class Node
  constructor: (@text='', @x=undefined, @y=undefined, @index=undefined) ->
  position: -> new Position(@x, @y)

@Node = Node