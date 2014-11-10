characterWidth = 8
lineHeight = 18
nodeMethods =
  position: -> if @link? then @link.midpoint() else createPosition(@x, @y)
  charge: -> @storedCharge || Math.min(-50, -1*@text.length*10)
  width: -> 90
  height: -> Math.max(1, Math.ceil(@text.length * characterWidth / @width())) * lineHeight

@createNode = (text='',x=undefined,y=undefined,index=undefined) ->
  _.extend identifiable(Object.create nodeMethods),
    text: text
    x: x
    y: y
    index: index
    storedCharge: undefined
    link: undefined
