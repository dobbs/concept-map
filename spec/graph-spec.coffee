describe "Graph", ->
  'manages collections of nodes and links'
  [graph] = []
  Given -> graph = createGraph()

  describe "empty", ->
    Then -> expect(graph.nodes()).toEqual []
    Then -> expect(graph.links()).toEqual []

  describe "add(node)", ->
    When -> graph.add(createNode('one fish'))
    Then -> expect(graph.nodes().length).toEqual 1
    Then -> expect(graph.nodes()[0].text).toEqual 'one fish'
    Then -> expect(graph.all.length).toEqual 1

  describe "add(link)", ->
    [nodeA, nodeB, link] = []
    Given ->
      nodeA = createNode("bricks and blocks")
      nodeB = createNode("chicks and clocks")
      graph.add(nodeB)
      link = createLink(nodeA, nodeB)
    When -> graph.add(link)
    Then -> expect(graph.links().length).toEqual 1
    Then -> expect(graph.nodes().length).toEqual 2
    Then -> expect(graph.all.length).toEqual 3
    Then -> expect(graph.all).toEqual [nodeB, nodeA, link]

  describe "remove(item)", ->
    [nodeA, nodeB, nodeC, nodeD, nodeE, nodeF, linkA, linkB] = []
    Given ->
      nodeA = createNode("bricks and blocks")
      nodeB = createNode("chicks and clocks")
      nodeC = createNode("fox")
      nodeD = createNode("sox")
      nodeE = createNode("in")
      nodeF = createNode("ticks and tocks")
      linkA = createLink(nodeA, nodeB)
      linkB = createLink(nodeC, nodeD, nodeE)
      graph.add linkA
      graph.add linkB
      graph.add nodeF

    describe "when node is a link source or target", ->
      When -> graph.remove(nodeA)
      Then -> expect(graph.nodes().length).toEqual 6
      When -> graph.remove(nodeB)
      Then -> expect(graph.nodes().length).toEqual 6
      When -> graph.remove(nodeE)
      Then -> expect(graph.nodes().length).toEqual 6

    describe "when node is not part of a link", ->
      When -> graph.remove(nodeF)
      Then -> expect(graph.nodes().length).toEqual 5

    describe "when item is a link", ->
      When -> graph.remove(linkB)
      describe "removes the link", ->
        Then -> expect(graph.links().length).toEqual 1
      describe "removes the annotation", ->
        Then -> expect(graph.nodes().length).toEqual 5
        Then -> expect(graph.nodes()).not.toContain nodeE
        describe "except when its part of another link", ->
          Given -> graph.add createLink(nodeE, nodeF)
          Then -> expect(graph.nodes().length).toEqual 6
          Then -> expect(graph.nodes()).toContain nodeE
      describe "preserves the source and target", ->
        Then -> expect(graph.nodes()).toContain nodeC
        Then -> expect(graph.nodes()).toContain nodeD
      