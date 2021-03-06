describe "Linked Links", ->
  # These tests verify the geometry of creating links between the
  # annotations of other links.  Originally I was going to let
  # createLink() use other links directly.  I've decided the model is
  # cleaner if I use nodes to hold the annotations and let links be
  # created to those nodes.
  #
  # The tests, however, still use links (slightly modified) as a source
  # or target of another link.  What links are really doing is connecting
  # objects that have a position() method that returns {x:.., y:...}.
  # In the real code (as of 21 Nov 2014) only nodes now have such a
  # position method().
  createPositionedLink = (source, target) ->
    link = createLink(source, target)
    link.position = link.midpoint
    link
  [source, target, link, choices] = []
  Given ->
    choices = _.range(10, 100, 5)
    source = createNode("source")
    target = createNode("target")
    [source.x, source.y, target.x, target.y] = _.sample(choices, 4)
    link = createPositionedLink(source, target)
   
  describe "with a linear link for the source", ->
    [linkAndNode, differentTarget] = []
    Given ->
      differentTarget = createNode("different target")
      [differentTarget.x, differentTarget.y] = _.sample(choices, 2)
      linkAndNode = createPositionedLink(link, differentTarget)
      linkAndNode.position = linkAndNode.midpoint

    describe "constructor", ->
      Then -> expect(linkAndNode.source).toEqual link

    describe "use the source's midpoint for its position", ->
      Then -> expect(linkAndNode.source.position()).toEqual link.midpoint()

    describe "midpoint() is equidistant from source's midpoint and the target node", ->
      [distanceStoM, distanceMtoT] = []
      Given ->
        midpoint = linkAndNode.midpoint()
        distanceStoM = geom.distance(link, midpoint)
        distanceMtoT = geom.distance(midpoint, differentTarget)
      Then -> expect(Math.abs(distanceStoM - distanceMtoT)).toBeLessThan 0.0001

  describe "with a linear link for the target", ->
    [nodeAndLink, differentSource] = []
    Given ->
      differentSource = createNode("different source")
      [differentSource.x, differentSource.y] = _.sample(choices, 2)
      nodeAndLink = createPositionedLink(differentSource, link)
      nodeAndLink.position = nodeAndLink.midpoint
    describe "midpoint() is equidistant from source node and the target's midpoint", ->
      [distanceStoM, distanceMtoT] = []
      Given ->
        midpoint = nodeAndLink.midpoint()
        distanceStoM = geom.distance(differentSource, midpoint)
        distanceMtoT = geom.distance(midpoint, link)
      Then -> expect(Math.abs(distanceStoM - distanceMtoT)).toBeLessThan 0.0001

  describe "with a circular links for source or target", ->
    [expectDistance, circLink, differentSource, differentTarget,
      circLinkAndNode, nodeAndCircLink] = [10]
    Given ->
      circLink = createPositionedLink(target, target)
      circLink.distance = -> expectDistance
      differentSource = createNode("different source")
      differentTarget = createNode("different target")
      [differentSource.x, differentSource.y, differentTarget.x, differentTarget.y] =
        _.sample(choices, 4)
      circLinkAndNode = createPositionedLink(circLink, differentTarget)
      nodeAndCircLink = createPositionedLink(differentSource, circLink)

    describe "midpoint() of circular link and node", ->
      [distanceStoM, distanceMtoT] = []
      Given ->
        midpoint = circLinkAndNode.midpoint()
        distanceStoM = geom.distance(circLink, midpoint)
        distanceMtoT = geom.distance(midpoint, differentTarget)
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
        distanceStoM = geom.distance(differentSource, midpoint)
        distanceMtoT = geom.distance(midpoint, circLink)
      Then -> expect(Math.abs(distanceStoM - distanceMtoT)).toBeLessThan 0.0001
      