describe "Linear Links", ->
  [source, target, link] = []
  Given ->
    source = new Node("source")
    target = new Node("target")
    choices = _.range(10, 100, 5)
    [source.x, source.y] = [_.sample(choices), _.sample(choices)]
    [target.x, target.y] = [_.sample(choices), _.sample(choices)]

  describe "constructor", ->
    When -> link = new Link(source, target, "annotation")
    Then -> expect(link.source).toEqual source
    Then -> expect(link.target).toEqual target
    Then -> expect(link.annotation).toEqual "annotation"
        
  describe "isCircular()", ->
    When -> link = new Link(source, target)
    Then -> expect(link.isCircular()).toBeFalsy()

  describe "midpoint()", ->
    [sourceToMidpoint, midpointToTarget] = []
    Given -> link = new Link(source, target)
    When ->
      midpoint = link.midpoint()
      [sourceToMidpointX, sourceToMidpointY] = [source.x - midpoint.x, source.y - midpoint.y]
      [midpointToTargetX, midpointToTargetY] = [midpoint.x - target.x, midpoint.y - target.y]
      sourceToMidpoint = Math.sqrt(
        sourceToMidpointX*sourceToMidpointX + sourceToMidpointY*sourceToMidpointY)
      midpointToTarget = Math.sqrt(
        midpointToTargetX*midpointToTargetX + midpointToTargetY*midpointToTargetY)
    Then -> expect(Math.abs(sourceToMidpoint - midpointToTarget)).toBeLessThan 0.0001 
