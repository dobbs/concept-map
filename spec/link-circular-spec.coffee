describe "Circular Links", ->
  [expectDistance, source, target, link, choices] = [10]
  Given -> choices = _.range(10, 100, 5)
  Given -> source = new Node("source")
  Given -> [source.x, source.y] = [_.sample(choices), _.sample(choices)]
  Given -> link = new Link(source, source, "annotation")
  Given -> link.distance = -> expectDistance
  Then -> expect(link.isCircular()).toBeTruthy()
   
  describe "midpoint(center)", ->
    [midpoint, center] = []
    Given -> center = {x: 50, y: 50}
    Given -> midpoint = link.midpoint(center)

    describe "center, midpoint and source must be colinear", ->
      [midpointToCenterSlope, centerToSourceSlope] = []
      When -> midpointToCenterSlope = (midpoint.y - center.y) / (midpoint.x - center.x)
      When -> centerToSourceSlope = (center.y - source.y) / (center.x - source.x)
      Then -> expect(Math.abs(centerToSourceSlope - centerToSourceSlope)).toBeLessThan 0.0001

    describe "midpoint must be link.distance from source.position", ->
      [actualDistance] = []
      When ->
        [dx, dy] = [midpoint.x - source.x, midpoint.y - source.y]
        actualDistance = Math.sqrt(dx*dx + dy*dy)
      Then -> expect(Math.abs(expectDistance - actualDistance)).toBeLessThan 0.0001

    describe "source must be between midpoint and graph center", ->
      [centerToSource, centerToMidpoint] = []
      When ->
        [dx, dy] = [center.x - source.x, center.y - source.y]
        centerToSource = Math.sqrt(dx*dx + dy*dy)
      When ->
        [dx, dy] = [center.x - midpoint.x, center.y - midpoint.y]
        centerToMidpoint = Math.sqrt(dx*dx + dy*dy)
      Then -> expect(centerToSource).toBeLessThan(centerToMidpoint)
