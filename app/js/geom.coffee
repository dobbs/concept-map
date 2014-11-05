class Geom
  @distance: (a, b) ->
    [dx, dy] = @_delta a, b
    Math.sqrt(dx*dx + dy*dy)

  @slope: (a, b) ->
    [dx, dy] = @_delta a, b
    dy / dx

  @unitVector: (a, b) ->
    [dx, dy] = @_delta a, b
    m = @distance a, b
    [dx/m, dy/m]

  @graphCenter: -> new Position(50, 50)

  @_delta: (a, b) ->
    [pa, pb] = [a.position(), b.position()]
    [pa.x - pb.x, pa.y - pb.y]
      
@Geom = Geom