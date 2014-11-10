graphPresenterMethods =
  startLayoutAnimation: ->
    @force
      .nodes(@graph.nodes())
      .links(@graph.links())
      .start()

@graphPresenter = (svg, graph) ->
  w = svg.node().attributes.width.value
  h = svg.node().attributes.height.value
  force = d3.layout.force()
    .charge((node) -> node.charge())
    .linkDistance((link) -> link.distance())
    .size([w, h])
  _.extend Object.create(graphPresenterMethods),
    svg: svg
    graph: graph
    force: force
