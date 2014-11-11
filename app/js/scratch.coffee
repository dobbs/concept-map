@scratch = ->
  svg = d3.select '[data-id=svg]'
  graph = createGraph()
  np = nodesPresenter svg, graph
  lp = linksPresenter svg, graph
  gp = graphPresenter svg, graph
  graph.onChange ->
    np.updateDomElements()
    lp.updateDomElements()
    gp.startLayoutAnimation()
  gp.force.on "tick", ->
    np.updateDomElementAttributes()
    lp.updateDomElementAttributes()
  scratch = 
    svg: svg
    graph: graph
    np: np
    lp: lp
    gp: gp
    init: ->
      @source = createNode 'fox'
      @target = createNode 'sox'
      @note1 = createNode 'in'
      @link1 = createLink @source, @target, @note1
      @note2 = createNode 'is crazy like a'
      @link2 = createLink @source, @source, @note2
      @note3 = createNode 'WAT?'
      @link3 = createLink @note2, @note2, @note3
      