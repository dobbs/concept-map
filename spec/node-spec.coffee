describe "Node", ->
  describe "constructor", ->
    [node] = []
    When -> node = new Node("one fish")
    Then -> expect(node.text).toEqual "one fish"
    Then -> expect(node.x).toBeUndefined()
    Then -> expect(node.y).toBeUndefined()

  describe "play nicely with d3.layout.force", ->
    [nodeA, nodeB] = []
    When ->
      [nodeA, nodeB] = [new Node("two fish"), new Node("red fish")]
      force = d3.layout.force()
        .size([100, 100])
        .nodes([nodeA, nodeB])
        .links([])
        .start()
    Then ->
      expect(_.every([nodeA.x, nodeA.y, nodeB.x, nodeB.y], _.isNumber))
        .toBeTruthy()
