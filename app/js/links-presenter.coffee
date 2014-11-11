linksPresenterMethods =
  updateDomElements: ->
    links = @d3dataJoin()
    links.exit().remove()
    links.enter().append('path')
      .attr('data-id', 'link')
    @
  updateDomElementAttributes: ->
    links = @d3dataJoin()
    links.attr('d', (link) ->
      if link.isCircular()
        [r, x, y] = [link.distance()/2, link.source.position().x, link.source.position().y]
        [x1, y1] = [link.midpoint().x, link.midpoint().y]
        "M#{x} #{y} A #{r} #{r}, 0, 0, 0, #{x1} #{y1} A #{r} #{r}, 0, 0, 0, #{x} #{y}"
      else
        [x1, y1] = [link.source.position().x, link.source.position().y]
        [x2, y2] = [link.target.position().x, link.target.position().y]
        "M#{x1} #{y1} L#{x2} #{y2}"
    ).style('fill', 'none')
    @

@linksPresenter = (svg, graph) ->
  _.extend Object.create(linksPresenterMethods),
    svg: svg
    graph: graph
    d3dataJoin: -> svg.selectAll('[data-id=link]').data(graph.links())
