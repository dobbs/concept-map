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
  annotationLength: -> if @annotation? then @annotation.text.length else 0
  distance: -> @storedDistance ||
    Math.max(50, @source.text.length + @target.text.length + @annotationLength())
  
@createLink = (source, target, annotation=undefined) ->
  link = _.extend identifiable(Object.create linkMethods),
    source: source
    target: target
    annotation: annotation
    storedDistance: undefined
  if annotation?
    annotation.link = link
  link