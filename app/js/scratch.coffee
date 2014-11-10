@scratch = ->
  svg = d3.select '[data-id=svg]'
  graph = createGraph()
  np = nodesPresenter svg, graph
  gp = graphPresenter svg, graph
  graph.onChange ->
    np.updateDomElements()
    gp.startLayoutAnimation()
  gp.force.on "tick", -> np.updateDomElementAttributes()
  scratch = 
    svg: svg
    graph: graph
    np: np
    gp: gp
