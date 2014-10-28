describe "Link", ->
  [source, target, link, choices] = []
  Given -> source = new Node("source")
  Given -> target = new Node("target")
  Given -> choices = _.range(10, 100, 5)
  Given -> [source.x, source.y] = [_.sample(choices), _.sample(choices)]
  Given -> [target.x, target.y] = [_.sample(choices), _.sample(choices)]

  describe "linear", ->
    Given -> link = new Link(source, target, "annotation")
    Then -> expect(link.isCircular()).toBeFalsy()

    describe "constructor", ->
      Then -> expect(link.source).toEqual source
      Then -> expect(link.target).toEqual target
      Then -> expect(link.annotation).toEqual "annotation"
          
    describe "midpoint", ->
      [midpoint, distanceX1, distanceY1, distanceX2, distanceY2] = []
      When -> midpoint = link.midpoint()
      When -> [distanceX1, distanceY1] = [source.x - midpoint.x, source.y - midpoint.y]
      When -> [distanceX2, distanceY2] = [midpoint.x - target.x, midpoint.y - target.y]
      Then -> expect(Math.abs(distanceX1 - distanceX2)).toBeLessThan 0.0001 
      Then -> expect(Math.abs(distanceY1 - distanceY2)).toBeLessThan 0.0001 

  describe "circular", ->
    [expectDistance] = []
    Given -> link = new Link(source, source, "annotation")
    Given -> expectDistance = 10
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
