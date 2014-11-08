linkPrototype =
  isCircular: -> @source is @target
  midpoint: ->
    if @isCircular()
      [unitx, unity] = geom.unitVector(@source, geom.graphCenter())
      p = @source.position()
      createPosition(p.x + @distance()*unitx, p.y + @distance()*unity)
    else
      [s, t] = [@source.position(), @target.position()]
      createPosition((s.x + t.x)/2, (s.y + t.y)/2)
  distance: ->
    Math.max(50, @source.text.length + @target.text.length + @text.length)
  position: -> @midpoint()

@createLink = (source, target, text='') ->
  link = Object.create linkPrototype
  identifiable link
  _.extend link,  
    source: source
    target: target
    text: text

