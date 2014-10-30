describe "Linear Links", ->
  [source, target, link] = []
  Given ->
    source = new Node("source")
    target = new Node("target")
    link = new Link(source, target, "annotation")

  describe "constructor", ->
    Then -> expect(link.source).toEqual source
    Then -> expect(link.target).toEqual target
    Then -> expect(link.annotation).toEqual "annotation"
        
  describe "isCircular()", ->
    Then -> expect(link.isCircular()).toBeFalsy()

  describe "midpoint()", ->
    [sourceToMidpoint, midpointToTarget] = []
    Given ->
      [sx, sy, tx, ty] = _.sample(_.range(10, 100, 5), 4)
      source.position = -> new Position(sx, sy)
      target.position = -> new Position(tx, ty)
    When ->
      midpoint = link.midpoint()
      sourceToMidpoint = Geom.distance(source, midpoint)
      midpointToTarget = Geom.distance(midpoint, target)
    Then -> expect(Math.abs(sourceToMidpoint - midpointToTarget)).toBeLessThan 0.0001 
