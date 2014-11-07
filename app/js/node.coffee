class Node extends Identifiable
  constructor: (@text='', @x=undefined, @y=undefined, @index=undefined) -> super
  position: -> new Position(@x, @y)

@Node = Node