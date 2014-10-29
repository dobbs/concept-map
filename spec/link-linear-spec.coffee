describe "Linear Links", ->
  [source, target, link, choices] = []
  Given -> source = new Node("source")
  Given -> target = new Node("target")
  Given -> choices = _.range(10, 100, 5)
  Given -> [source.x, source.y] = [_.sample(choices), _.sample(choices)]
  Given -> [target.x, target.y] = [_.sample(choices), _.sample(choices)]
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
