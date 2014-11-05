class Link
  constructor: (@source, @target, @text='') ->
  isCircular: -> @source is @target
  midpoint: ->
    if @isCircular()
      [unitx, unity] = Geom.unitVector(@source, Geom.graphCenter())
      p = @source.position()
      new Position(p.x + @distance()*unitx, p.y + @distance()*unity)
    else
      [s, t] = [@source.position(), @target.position()]
      new Position((s.x + t.x)/2, (s.y + t.y)/2)
  distance: ->
    Math.max(50, @source.text.length + @target.text.length + @text.length)
  position: -> @midpoint()

@Link = Link