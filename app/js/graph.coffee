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
class KeyboardFsm
  constructor: (selection) ->
    @selection = selection
    @state = @idling
    @selection.on "keyup", => @keyup()
  keyup: ->
    @keyCode = d3.event.keyCode
    @key = String.fromCharCode(@keyCode)
    @el = @selection.node()
    @state()
    restart()
  focus: -> @selection.node().focus()
  createPointNode: (text) ->
    pointnode =
      type: "pointnode"
      text: text
    nodes.push(pointnode)
    pointnode
  createLinkNode: (link) ->
    linknode =
      type: "linknode"
      text: ""
      x: midpoint(link).x
      y: midpoint(link).y
    nodes.push(linknode)
    linknode
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
    @nodeToLabel = @createPointNode @el.value
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
    @currentLink =
      source: @source
      target: @target
      linknode: null
    links.push(@currentLink)
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
    linknode = @createLinkNode(@currentLink)
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
    
nodes = if localStorage.nodes then JSON.parse(localStorage.nodes) else []
links = if localStorage.links
  _(JSON.parse(localStorage.links)).map (link) ->
    link.linknode = nodes[link.linknode]
    link
else
  []
pointnodes = -> _(nodes).filter (n) -> n.type is "pointnode"
linknodes = -> _(nodes).filter (n) -> n.type is "linknode"

@saveGraph = ->
  localStorage.nodes = JSON.stringify(nodes)
  cleanLinks = links.map (orig) ->
    source: orig.source.index
    target: orig.target.index
    linknode: orig.linknode.index
  localStorage.links = JSON.stringify(cleanLinks)

force = d3.layout.force()
  .charge((d)-> -50 - (d.text.length * 2))
  .linkDistance(50)
  .size([w, h])
  .nodes(nodes)
  .links(links)

svg = d3.select("body").append("svg")
  .attr("width", w)
  .attr("height", h)

keyboardListener = d3.select("body").append("input")
  .attr("id", "keyboardListener")
  .attr("type", "text")
  .attr("size", 75)
  .attr("autofocus", 1)

fsm = new KeyboardFsm(keyboardListener)

computeNodePosition = (node) ->
  if node.type is "linknode"
    link = links.filter((link) -> link.linknode is node)[0]
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
class PointnodesPresenter
  constructor: (@dataFn) ->
  tick: ->
    join = svg.selectAll(".pointnode").data(@dataFn())
      .attr("x", (d) -> d.x - nodeWidth/2)
      .attr("y", (d) -> d.y - nodeHeight(d)/2)
      .attr("width", nodeWidth)
      .attr("height", nodeHeight)
    join.selectAll("p")
      .text((d) -> d.text)
      .style "color", nodeColor
  restart: ->
    join = svg.selectAll(".pointnode").data(@dataFn())
    join.exit().remove()
    join.enter().append("foreignObject").attr("class", "pointnode")
      .append("xhtml:body")
      .append("p")

pointnodesPresenter = new PointnodesPresenter pointnodes

partitionedLinks = -> _(links).partition (its) -> its.source is its.target
otherLinks = -> partitionedLinks()[1]
selfLinks = -> partitionedLinks()[0]

class OtherLinksPresenter
  constructor: (@dataFn) ->
  tick: ->
    join = svg.selectAll("g.link").data(@dataFn())
    join.selectAll("line")
      .attr("x1", (d) -> computeNodePosition(d.source).x)
      .attr("y1", (d) -> computeNodePosition(d.source).y)
      .attr("x2", (d) -> computeNodePosition(d.target).x)
      .attr("y2", (d) -> computeNodePosition(d.target).y)
    join.selectAll(".linknode")
      .attr("x", (d) -> midpoint(d).x - nodeWidth/2)
      .attr("y", (d) ->
        midpoint(d).y - nodeHeight(d.linknode)/2)
      .attr("width", nodeWidth)
      .attr("height", (d) -> nodeHeight(d.linknode))
      .selectAll("p")
        .text((d) -> d.linknode?.text)
        .style "color", (d) -> nodeColor(d.linknode)
  restart: ->
    join = svg.selectAll("g.link").data(@dataFn())
    join.exit().remove()
    it = join.enter().append("g").attr("class", "link")
    it.append("line")
    it.append("foreignObject").attr("class", "linknode")
      .append("xhtml:body").append("p")
    
linksPresenter = new OtherLinksPresenter otherLinks

class SelfLinksPresenter
  constructor: (@dataFn) ->
  tick: ->
    join = svg.selectAll("g.selflink").data(@dataFn())
    join.selectAll(".linknode")
      .attr("x", (d) -> outside(d.source).x - nodeWidth/2)
      .attr("y", (d) -> outside(d.source).y - nodeHeight(d.linknode)/2)
      .attr("width", nodeWidth)
      .attr("height", (d) -> nodeHeight(d.linknode))
      .selectAll("p")
        .text((d) -> d.linknode?.text)
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
    
    
selflinksPresenter = new SelfLinksPresenter selfLinks

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

d3.select('body').on "click", fsm.focus.bind(fsm)
fsm.focus()
restart();

@pointnodes = pointnodes
@linknodes = linknodes
@force = force
@nodes = nodes
@links = links
@fsm = fsm
