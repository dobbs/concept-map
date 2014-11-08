nodePrototype =
  position: -> createPosition(@x, @y)

@createNode = (text='',x=undefined,y=undefined,index=undefined) ->
  node = Object.create nodePrototype
  identifiable node  
  _.extend node,
    text: text
    x: x
    y: y
    index: index
