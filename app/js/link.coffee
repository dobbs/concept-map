linkMethods =
  isCircular: -> @source is @target
  midpoint: ->
    if @isCircular()
      [unitx, unity] = geom.unitVector(@source, geom.graphCenter())
      p = @source.position()
      createPosition(p.x + @distance()*unitx, p.y + @distance()*unity)
    else
      [s, t] = [@source.position(), @target.position()]
      createPosition((s.x + t.x)/2, (s.y + t.y)/2)
  extraDistance: -> 0
  distance: -> Math.max(50, @source.text.length + @target.text.length + @extraDistance())
  
@createLink = (source, target, text='') ->
  _.extend identifiable(Object.create linkMethods),  
    source: source
    target: target

