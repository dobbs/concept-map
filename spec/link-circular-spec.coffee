describe "Circular Links", ->
  [expectDistance, source, target, link] = [10]
  Given ->
    source = createNode("source")
    link = createLink(source, source)
    link.distance = -> expectDistance

  describe "isCircular()", ->
    Then -> expect(link.isCircular()).toBeTruthy()
   
  describe "midpoint()", ->
    [midpoint, center] = []
    Given ->
      [sx, sy] = _.sample(_.range(10, 100, 5), 2)
      source.position = -> createPosition(sx, sy)
      center = geom.graphCenter()
      midpoint = link.midpoint()

    describe "center, midpoint and source must be colinear", ->
      Then ->
        slopeCM = geom.slope(center, midpoint)
        slopeMS = geom.slope(midpoint, source)
        expect(Math.abs(slopeCM - slopeMS)).toBeLessThan 0.0001

    describe "midpoint must be link.distance from source.position", ->
      [actualDistance] = []
      When -> actualDistance = geom.distance(midpoint, source)
      Then -> expect(Math.abs(expectDistance - actualDistance)).toBeLessThan 0.0001

    describe "source must be between midpoint and graph center", ->
      [centerToSource, centerToMidpoint] = []
      When -> centerToSource = geom.distance(center, source)
      When -> centerToMidpoint = geom.distance(center, midpoint)
      Then -> expect(centerToSource).toBeLessThan(centerToMidpoint)
