describe "Circular Links", ->
  [expectDistance, source, target, link] = [10]
  Given ->
    source = new Node("source")
    link = new Link(source, source, "annotation")
    link.distance = -> expectDistance

  describe "isCircular()", ->
    Then -> expect(link.isCircular()).toBeTruthy()
   
  describe "midpoint(center)", ->
    [midpoint, center] = []
    Given ->
      [sx, sy] = _.sample(_.range(10, 100, 5), 2)
      source.position = -> new Position(sx, sy)
      center = new Position(50, 50)
      midpoint = link.midpoint(center)

    describe "center, midpoint and source must be colinear", ->
      Then ->
        slopeCM = Geom.slope(center, midpoint)
        slopeMS = Geom.slope(midpoint, source)
        expect(Math.abs(slopeCM - slopeMS)).toBeLessThan 0.0001

    describe "midpoint must be link.distance from source.position", ->
      [actualDistance] = []
      When -> actualDistance = Geom.distance(midpoint, source)
      Then -> expect(Math.abs(expectDistance - actualDistance)).toBeLessThan 0.0001

    describe "source must be between midpoint and graph center", ->
      [centerToSource, centerToMidpoint] = []
      When -> centerToSource = Geom.distance(center, source)
      When -> centerToMidpoint = Geom.distance(center, midpoint)
      Then -> expect(centerToSource).toBeLessThan(centerToMidpoint)
