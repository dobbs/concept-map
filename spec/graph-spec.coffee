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
      link = createLink(nodeA, nodeB, "tongue numb")
    When -> graph.add(link)
    Then -> expect(graph.links().length).toEqual 1
    Then -> expect(graph.nodes().length).toEqual 2
    Then -> expect(graph.all.length).toEqual 3
    Then -> expect(graph.all).toEqual [nodeB, nodeA, link]
