@scratch = ->
  svg = d3.select '[data-id=svg]'
  graph = createGraph()
  np = nodesPresenter svg, graph
  lp = linksPresenter svg, graph
  gp = graphPresenter svg, graph
  antenna.on 'graphChanged', ->
    np.updateDomElements()
    lp.updateDomElements()
    gp.startLayoutAnimation()
  gp.force.on "tick", ->
    np.updateDomElementAttributes()
    lp.updateDomElementAttributes()
  source = createNode 'fox'
  target = createNode 'sox'
  note1 = createNode 'in'
  link1 = createLink source, target, note1
  note2 = createNode 'is crazy like a'
  link2 = createLink source, source, note2
  note3 = createNode 'WAT?'
  link3 = createLink note2, note2, note3

  graph.add(link1)
  scratch = 
    svg: svg
    graph: graph
    np: np
    lp: lp
    gp: gp
    source: source
    target: target
    note1: note1
    link1: link1
    note2: note2
    link2: link2
    note3: note3
    link3: link3
