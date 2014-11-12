graphPresenterMethods =
  startLayoutAnimation: ->
    @force
      .nodes(@graph.nodes())
      .links(@graph.links())
      .start()

@graphPresenter = (svg, graph) ->
  w = svg.node().attributes.width.value
  h = svg.node().attributes.height.value
  geom.graphCenter = -> createPosition(parseInt(w/2), parseInt(h/2))
  force = d3.layout.force()
    .charge((node) -> node.charge())
    .linkDistance((link) -> link.distance())
    .size([w, h])
  antenna.drag = force.drag()
    .on "dragstart", (d) -> d3.select(@).classed('fixed', d.fixed=true)
  antenna.on 'nodeChanged', -> force.resume()
  _.extend Object.create(graphPresenterMethods),
    graph: graph
    force: force
