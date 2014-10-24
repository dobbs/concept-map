describe "Node", ->
  describe "constructor", ->
    When -> @node = new Node("one fish")
    Then -> expect(@node.text).toEqual "one fish"
    Then -> expect(@node.x).toBeUndefined()
    Then -> expect(@node.y).toBeUndefined()

  describe "play nicely with d3.layout.force", ->
    When ->
      @nodes = [new Node("two fish"), new Node("red fish")]
      force = d3.layout.force()
        .size([100, 100])
        .nodes(@nodes)
        .links([])
        .start()
    Then ->
      expect(_.every(_.flatten(_.map(@nodes, (n) -> [n.x, n.y])), _.isNumber))
        .toBeTruthy()
