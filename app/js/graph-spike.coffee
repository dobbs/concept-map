[w, h] = [400, 400]

RETURN = 13
LEFTARROW = 37
UPARROW = 38
RIGHTARROW = 39
DOWNARROW = 40
ESC = 27
CONTROL = 17
SHIFT = 16
OPTION = 18
COMMAND = 91

midpoint = (link) ->
  x: link.target.x + (link.source.x - link.target.x) / 2
  y: link.target.y + (link.source.y - link.target.y) / 2

outside = (position) ->
  dx = w/2 - position.x
  dy = h/2 - position.y
  ux = dx/Math.sqrt(dx*dx + dy*dy)
  uy = dy/Math.sqrt(dx*dx + dy*dy)
  x: position.x - 50*ux
  y: position.y - 50*uy

computeNodePosition = (node) ->
  if node.type is "linknode"
    link = links.filter((link) -> link.linknode is node)[0]
    if link.source is link.target
      outside(node)
    else
      midpoint(link)
  else
    x: node.x
    y: node.y

computeSelfLinkPath = (d) ->
  r = 25 # linkDistance / 2
  position = computeNodePosition(d.source)
  [x, y] = [position.x, position.y]
  [x1, y1] = [outside(position).x, outside(position).y]
  "M#{x} #{y} A #{r} #{r}, 0, 0, 0, #{x1} #{y1} A #{r} #{r}, 0, 0, 0, #{x} #{y}"

nodeWidth = 90
charWidth = 8
lineHeight = 18

nodeHeight = (d) ->
  (if d? then Math.ceil(d.text.length * charWidth / nodeWidth) else 1) * lineHeight

nodeColor = (d) ->
  switch d
    when fsm.source
      "#d00"
    when fsm.target
      "#0dd"
    else
      "#000"

calculators =
  nodeWidth: nodeWidth
  nodeHeight: nodeHeight
  nodeColor: nodeColor
  computeNodePosition: computeNodePosition
  midpoint: midpoint
  outside: outside
  
nodes = if localStorage.nodes then JSON.parse(localStorage.nodes) else []

links = if localStorage.links
  _(JSON.parse(localStorage.links)).map (link) ->
    link.linknode = nodes[link.linknode]
    link
else
  []

pointnodes = -> _(nodes).filter (n) -> n.type is "pointnode"

linknodes = -> _(nodes).filter (n) -> n.type is "linknode"

partitionedLinks = -> _(links).partition (its) -> its.source is its.target

otherLinks = -> partitionedLinks()[1]

selfLinks = -> partitionedLinks()[0]

createPointNode = (text) ->
  pointnode =
    type: "pointnode"
    text: text
  nodes.push(pointnode)
  pointnode

createLinkNode = (link, calculators) ->
  linknode =
    type: "linknode"
    text: ""
    x: calculators.midpoint(link).x
    y: calculators.midpoint(link).y
  nodes.push(linknode)
  linknode

createLink = (source, target, linknode) ->
  link = 
    source: source
    target: target
    linknode: linknode
  links.push(link)
  link


@saveGraph = ->
  localStorage.nodes = JSON.stringify(nodes)
  cleanLinks = links.map (orig) ->
    source: orig.source.index
    target: orig.target.index
    linknode: orig.linknode.index
  localStorage.links = JSON.stringify(cleanLinks)

class KeyboardFsm
  constructor: (selection) ->
    @selection = selection
    @el = @selection.node()
    @state = @idling
    @selection.on "keyup", => @keyup()
  keyup: ->
    @keyCode = d3.event.keyCode
    @key = String.fromCharCode(@keyCode)
    @state()
    restart()
  focus: -> @el.focus()
  idling: ->
    switch @keyCode
      when ESC
        @state = @beginChoosingSource
        @state()
      else
        if /\w/.test @key
          @state = @createAndBeginLabeling
          @state()
  createAndBeginLabeling: ->
    @nodeToLabel = createPointNode @el.value
    @state = @labeling
  labeling: ->
    switch @keyCode
      # when ESC
      #   @state = @beginLinking
      #   @state()
      when RETURN
        @state = @cleanupLinking
        return @state()
      else
        @nodeToLabel.text = @el.value
  beginChoosingSource: ->
    if @source is undefined
      @source = pointnodes()[0]
    @nodeToLabel = @source
    @el.value = @nodeToLabel.text
    @sourceIndex = @source.index
    @target = undefined
    @targetIndex = undefined
    @currentLink = undefined
    @cancelFn = -> null
    @state = @choosingSource
  choosingSource: ->
    switch @keyCode
      when ESC
        @state = @cancelLinking
        return @state()
      when RETURN
        @state = @beginLinking
        return @state()
      when LEFTARROW, UPARROW
        @sourceIndex -= 1
      when RIGHTARROW, DOWNARROW
        @sourceIndex += 1
      else
        if /\w/.test @key
          @state = @labeling
          return @state()
    if @sourceIndex < 0
      @sourceIndex = nodes.length - 1
    else if @sourceIndex == nodes.length
      @sourceIndex = 0
    @source = nodes[@sourceIndex]
    @nodeToLabel = @source
    @el.value = @nodeToLabel.text
  beginLinking: ->
    if @target is undefined
      @target = @source
    @targetIndex = @target.index
    @currentLink = createLink(@source, @target, null)
    @cancelFn = ->
      links.pop()
      @cancelFn = -> null
    @state = @choosingTarget
  choosingTarget: ->
    switch @keyCode
      when ESC
        @state = @cancelLinking
        return @state()
      when RETURN
        @state = @beginLabelingLink
        return @state()
      when LEFTARROW, UPARROW
        @targetIndex -= 1
      when RIGHTARROW, DOWNARROW
        @targetIndex += 1
    if @targetIndex < 0
      @targetIndex = nodes.length - 1
    else if @targetIndex == nodes.length
      @targetIndex = 0
    @target = nodes[@targetIndex]
    @currentLink.target = @target
  cancelLinking: ->
    if _(@cancelFn).isFunction()
      @cancelFn()
    @state = @cleanupLinking
    @state()
  beginLabelingLink: ->
    @el.value = ""
    linknode = createLinkNode(@currentLink, calculators)
    @currentLink.linknode = linknode
    @state = @labelingLink
  labelingLink: ->
    switch @keyCode
      when RETURN
        @state = @cleanupLinking
        @state()
      else
        @currentLink.linknode.text = @el.value
  cleanupLinking: ->
    @source = undefined
    @target = undefined
    @sourceIndex = undefined
    @targetIndex = undefined
    @currentLink = undefined
    @nodeToLabel = undefined
    @el.value = ""
    @cancelFn = -> null
    @state = @idling
    
force = d3.layout.force()
  .charge((d) -> Math.min(-50, -1*d.text.length*10))
  .linkDistance((d) ->
    Math.max(
      50,
      _([d.source, d.linknode, d.target]).reduce(
        (memo, node) -> memo + (if node? then node.text.length else 20),
        0
      )
    )
  )
  .size([w, h])
  .nodes(nodes)
  .links(links)

graph = d3.select("body").append("div")
  .attr("id", "graph")
svg = graph.append("svg")
  .attr("width", w)
  .attr("height", h)

panels = d3.select("body").append("div")
  .attr("id", "panels")

nodeCreator = panels.append("div")
  .attr("class", "panel")
keyboardListener = nodeCreator.append("input")
  .attr("id", "keyboardListener")
  .attr("type", "text")
  .attr("size", 40)
  .attr("autofocus", 1)
fsm = new KeyboardFsm(keyboardListener)

class PointnodesPresenter
  constructor: (@svg, @calculators, @dataFn) ->
  tick: ->
    join = @svg.selectAll(".pointnode").data(@dataFn())
      .attr("x", (d) => d.x - @calculators.nodeWidth/2)
      .attr("y", (d) => d.y - @calculators.nodeHeight(d)/2)
      .attr("width", @calculators.nodeWidth)
      .attr("height", @calculators.nodeHeight)
    join.selectAll("p")
      .text((d) -> d.text)
      .style "color", @calculators.nodeColor
  restart: ->
    join = svg.selectAll(".pointnode").data(@dataFn())
    join.exit().remove()
    join.enter().append("foreignObject").attr("class", "pointnode")
      .append("xhtml:body")
      .append("p")

pointnodesPresenter = new PointnodesPresenter svg, calculators, pointnodes

class OtherLinksPresenter
  constructor: (@svg, @calculators, @dataFn) ->
  tick: ->
    join = @svg.selectAll("g.link").data(@dataFn())
    join.selectAll("line")
      .attr("x1", (d) => @calculators.computeNodePosition(d.source).x)
      .attr("y1", (d) => @calculators.computeNodePosition(d.source).y)
      .attr("x2", (d) => @calculators.computeNodePosition(d.target).x)
      .attr("y2", (d) => @calculators.computeNodePosition(d.target).y)
    join.selectAll(".linknode")
      .attr("x", (d) => @calculators.midpoint(d).x - @calculators.nodeWidth/2)
      .attr("y", (d) =>
        @calculators.midpoint(d).y - @calculators.nodeHeight(d.linknode)/2)
      .attr("width", @calculators.nodeWidth)
      .attr("height", (d) => @calculators.nodeHeight(d.linknode))
      .selectAll("p")
        .text((d) -> d.linknode?.text)
        .style "color", (d) => @calculators.nodeColor(d.linknode)
  restart: ->
    join = svg.selectAll("g.link").data(@dataFn())
    join.exit().remove()
    it = join.enter().append("g").attr("class", "link")
    it.append("line")
    it.append("foreignObject").attr("class", "linknode")
      .append("xhtml:body").append("p")
    
linksPresenter = new OtherLinksPresenter svg, calculators, otherLinks

class SelfLinksPresenter
  constructor: (@svg, @calculators, @dataFn) ->
  tick: ->
    join = @svg.selectAll("g.selflink").data(@dataFn())
    join.selectAll(".linknode")
      .attr("x", (d) => @calculators.outside(d.source).x - @calculators.nodeWidth/2)
      .attr("y", (d) => @calculators.outside(d.source).y - @calculators.nodeHeight(d.linknode)/2)
      .attr("width", nodeWidth)
      .attr("height", (d) => @calculators.nodeHeight(d.linknode))
      .selectAll("p")
        .text((d) -> d.linknode?.text)
        .style "color", (d) => @calculators.nodeColor(d.linknode)
    join.selectAll("path")
      .attr("d", computeSelfLinkPath)
      .style("fill", "none")
  restart: ->
    join = svg.selectAll("g.selflink").data(@dataFn())
    join.exit().remove()
    it = join.enter().append("g").attr("class", "selflink")
    it.append("path")
    it.append("foreignObject").attr("class", "linknode")
      .append("xhtml:body").append("p")
    
selflinksPresenter = new SelfLinksPresenter svg, calculators, selfLinks

tick = ->
  linksPresenter.tick()
  selflinksPresenter.tick()
  pointnodesPresenter.tick()

restart = ->
  linksPresenter.restart()
  selflinksPresenter.restart()
  pointnodesPresenter.restart()
  tick()
  fsm.focus()
  force.start()

force.on "tick", tick

# d3.select('body').on "click", fsm.focus.bind(fsm)
# fsm.focus()
# restart();

@pointnodes = pointnodes
@linknodes = linknodes
@force = force
@nodes = nodes
@links = links
@fsm = fsm