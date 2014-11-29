@scratch = ->
  svg = d3.select '[data-id=svg]'
  return 'Must identify the SVG DOM root with data-id="svg".' unless svg.node()?
  graph = createGraph()
  np = nodesPresenter svg, graph
  lp = linksPresenter svg, graph
  gp = graphPresenter svg, graph
  antenna.on 'graphChanged', ->
    np.updateDomElements()
    lp.updateDomElements()
    gp.startLayoutAnimation()
  antenna.on 'linkChanged', ->
    antenna.graphChanged("linkChanged", arguments...)
  antenna.on 'nodeChanged', ->
    antenna.graphChanged("nodeChanged", arguments...)

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
  ne = nodeEditor()
  le = linkEditor(link1)
  le.updateElementAttributes()
  listener = d3.select('input[data-id=listener]').node()
  kba = keyboardActions(listener, graph)

  document.body.addEventListener 'keyup', keyboard
  scratch = 
    svg: svg
    graph: graph
    np: np
    lp: lp
    gp: gp
    ne: ne
    le: le
    kba: kba
    source: source
    target: target
    note1: note1
    link1: link1
    note2: note2
    link2: link2
    note3: note3
    link3: link3

@x = @scratch()