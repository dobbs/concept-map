describe "Linked Links", ->
  [source, target, link, choices] = []
  Given ->
    choices = _.range(10, 100, 5)
    source = new Node("source")
    target = new Node("target")
    [source.x, source.y, target.x, target.y] = _.sample(choices, 4)
    link = new Link(source, target, "linked nodes")
   
  describe "with a linear link for the source", ->
    [linkAndNode, differentTarget] = []
    Given ->
      differentTarget = new Node("different target")
      [differentTarget.x, differentTarget.y] = _.sample(choices, 2)
      linkAndNode = new Link(link, differentTarget, "link and node")

    describe "constructor", ->
      Then -> expect(linkAndNode.source).toEqual link

    describe "use the source's midpoint for its position", ->
      Then -> expect(linkAndNode.source.position()).toEqual link.midpoint()

    describe "midpoint() is equidistant from source's midpoint and the target node", ->
      [distanceStoM, distanceMtoT] = []
      Given ->
        midpoint = linkAndNode.midpoint()
        distanceStoM = Geom.distance(link, midpoint)
        distanceMtoT = Geom.distance(midpoint, differentTarget)
      Then -> expect(Math.abs(distanceStoM - distanceMtoT)).toBeLessThan 0.0001

  describe "with a linear link for the target", ->
    [nodeAndLink, differentSource] = []
    Given ->
      differentSource = new Node("different source")
      [differentSource.x, differentSource.y] = _.sample(choices, 2)
      nodeAndLink = new Link(differentSource, link, "node and link")
    describe "midpoint() is equidistant from source node and the target's midpoint", ->
      [distanceStoM, distanceMtoT] = []
      Given ->
        midpoint = nodeAndLink.midpoint()
        distanceStoM = Geom.distance(differentSource, midpoint)
        distanceMtoT = Geom.distance(midpoint, link)
      Then -> expect(Math.abs(distanceStoM - distanceMtoT)).toBeLessThan 0.0001

  describe "with a circular links for source or target", ->
    [expectDistance, circLink, differentSource, differentTarget,
      circLinkAndNode, nodeAndCircLink] = [10]
    Given ->
      circLink = new Link(target, target, "circular link")
      circLink.distance = -> expectDistance
      differentSource = new Node("different source")
      differentTarget = new Node("different target")
      [differentSource.x, differentSource.y, differentTarget.x, differentTarget.y] =
        _.sample(choices, 4)
      circLinkAndNode = new Link(circLink, differentTarget, "circular link and node")
      nodeAndCircLink = new Link(differentSource, circLink, "node and circular link")

    describe "midpoint() of circular link and node", ->
      [distanceStoM, distanceMtoT] = []
      Given ->
        midpoint = circLinkAndNode.midpoint()
        distanceStoM = Geom.distance(circLink, midpoint)
        distanceMtoT = Geom.distance(midpoint, differentTarget)
        window.debug =
          circLink: circLink
          circLinkAndNode: circLinkAndNode
          differentTarget: differentTarget
          midpoint: midpoint
          distanceStoM: distanceStoM
          distanceMtoT: distanceMtoT
      Then -> expect(Math.abs(distanceStoM - distanceMtoT)).toBeLessThan 0.0001

    describe "midpoint() of node and circular link", ->
      [distanceStoM, distanceMtoT] = []
      Given ->
        midpoint = nodeAndCircLink.midpoint()
        distanceStoM = Geom.distance(differentSource, midpoint)
        distanceMtoT = Geom.distance(midpoint, circLink)
      Then -> expect(Math.abs(distanceStoM - distanceMtoT)).toBeLessThan 0.0001
      