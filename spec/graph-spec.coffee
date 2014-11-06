describe "Graph", ->
  'manages collections of nodes and links'
  [graph] = []
  Given -> graph = new Graph()

  describe "empty", ->
    Then -> expect(graph.nodes).toEqual []
    Then -> expect(graph.links).toEqual []

  describe "add(node)", ->
    When -> graph.add(new Node('one fish'))
    Then -> expect(graph.nodes.length).toEqual 1
    Then -> expect(graph.nodes[0].text).toEqual 'one fish'
    Then -> expect(graph.nodes[0].index).toEqual 0

  describe "link(sourceIndex, targetIndex, text)", ->
    [source, target] = []
    Given ->
      source = new Node('fox in sox')
      target = new Node('knox in box')
      graph.add(source)
      graph.add(target)
    When -> graph.link(0, 1, 'rhymes with')
    Then -> expect(graph.links.length).toEqual 1
    