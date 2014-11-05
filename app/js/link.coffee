class Link
  constructor: (@source, @target, @annotation) ->
  isCircular: -> @source is @target
  midpoint: ->
    if @isCircular()
      [unitx, unity] = Geom.unitVector(@source, Geom.graphCenter())
      p = @source.position()
      new Position(p.x + @distance()*unitx, p.y + @distance()*unity)
    else
      [s, t] = [@source.position(), @target.position()]
      new Position(t.x + (s.x - t.x) / 2, t.y + (s.y - t.y) / 2)
  position: -> @midpoint()
    

@Link = Link