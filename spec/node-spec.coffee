describe "Node", ->
  describe "createNode", ->
    [node] = []
    When -> node = createNode("one fish")
    Then -> expect(node.text).toEqual "one fish"
    Then -> expect(node.x).toBeUndefined()
    Then -> expect(node.y).toBeUndefined()

  describe "play nicely with d3.layout.force", ->
    [nodeA, nodeB] = []
    When ->
      [nodeA, nodeB] = [createNode("two fish"), createNode("red fish")]
      force = d3.layout.force()
        .size([100, 100])
        .nodes([nodeA, nodeB])
        .links([])
        .start()
    Then ->
      expect(_.every([nodeA.x, nodeA.y, nodeB.x, nodeB.y], _.isNumber))
        .toBeTruthy()

    describe "position uses keys from the d3 force layout", ->
      Then -> expect(nodeA.position().x).toEqual(nodeA.x)
      Then -> expect(nodeA.position().y).toEqual(nodeA.y)
      Then -> expect(nodeB.position().x).toEqual(nodeB.x)
      Then -> expect(nodeB.position().y).toEqual(nodeB.y)
        