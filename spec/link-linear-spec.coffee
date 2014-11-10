describe "Linear Links", ->
  [source, target, link] = []
  Given ->
    source = createNode("source")
    target = createNode("target")
    link = createLink(source, target)

  describe "constructor", ->
    Then -> expect(link.source).toEqual source
    Then -> expect(link.target).toEqual target
        
  describe "isCircular()", ->
    Then -> expect(link.isCircular()).toBeFalsy()

  describe "midpoint()", ->
    [sourceToMidpoint, midpointToTarget] = []
    Given ->
      [sx, sy, tx, ty] = _.sample(_.range(10, 100, 5), 4)
      source.position = -> createPosition(sx, sy)
      target.position = -> createPosition(tx, ty)
    When ->
      midpoint = link.midpoint()
      sourceToMidpoint = geom.distance(source, midpoint)
      midpointToTarget = geom.distance(midpoint, target)
    Then -> expect(Math.abs(sourceToMidpoint - midpointToTarget)).toBeLessThan 0.0001 
