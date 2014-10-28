class Link
  constructor: (@source, @target, @annotation) ->
  isCircular: -> @source is @target
  midpoint: (center=null) ->
    if @isCircular()
      [dx, dy] = [@source.x - center.x, @source.y - center.y]
      m = Math.sqrt(dx*dx + dy*dy)
      [unitx, unity] = [dx/m, dy/m]
      x: @source.x + @distance()*unitx
      y: @source.y + @distance()*unity
    else  
      x: @target.x + (@source.x - @target.x) / 2
      y: @target.y + (@source.y - @target.y) / 2

@Link = Link