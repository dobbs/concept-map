nodesPresenterMethods =
  updateDomElements: ->
    nodes = @d3dataJoin()
    nodes.exit().remove()
    nodes.enter().append("foreignObject").attr('data-id', 'node')
      .append('xhtml:body')
      .append('p')
    @
  updateDomElementAttributes: ->
    nodes = @d3dataJoin()
    nodes
      .attr('x', (node) -> node.position().x - node.width()/2)
      .attr('y', (node) -> node.position().y - node.height()/2)
      .attr('width', (node) -> node.width())
      .attr('height', (node) -> node.height())
    nodes.selectAll('p')
      .text((node) -> node.text)
      .attr('class', (node) -> node.style)
    @

@nodesPresenter = (svg, graph) ->
  _.extend Object.create(nodesPresenterMethods), 
    svg: svg
    graph: graph
    d3dataJoin: -> svg.selectAll('[data-id=node]').data(graph.nodes())
