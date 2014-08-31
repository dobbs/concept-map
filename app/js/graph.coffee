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
outside = (node) ->
  x: node.x - 1.5*(w/2 - node.x)
  y: node.y - 1.5*(h/2 - node.y)
class KeyboardFsm
  constructor: (selection) ->
    @selection = selection
    @state = @creating
    @selection.on "keyup", => @keyup()
  keyup: ->
    @keyCode = d3.event.keyCode
    @key = String.fromCharCode(@keyCode)
    @el = @selection.node()
    @state()
    restart()
  focus: -> @selection.node().focus()
  edit: (d) ->
    @selection.node().value = d.text
    @currentNode = d
    @state = @labeling
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
  beginLabeling: ->
    @currentNode = @createPointNode @selection.node().value
    @state = @labeling
  labeling: ->
    switch @keyCode
      when ESC
        @state = @beginLinking
        @state()
      when RETURN
        @el.setSelectionRange(0, @el.value.length)
        @state = @creating
      else
        @currentNode.text = @el.value
  creating: ->
    switch @keyCode
      when ESC
        @state = @beginLinking
        @state()
      else
        if /\w/.test @key
          @state = @beginLabeling
          @state()
  beginLinking: ->
    if @currentNode is undefined
      @currentNode = pointnodes()[0]
    @source = @currentNode
    @target = @currentNode
    @targetIndex = @currentNode.index
    @currentLink =
      source: @source
      target: @target
      linknode: null
    links.push(@currentLink)
    @state = @choosingTarget
  choosingTarget: ->
    loop
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
      break if @target.type is "pointnode" #skip linknodes when choosing a target
    @currentLink.target = @target
  cancelLinking: ->
    links.pop()
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
    @targetIndex = undefined
    @currentLink = undefined
    @currentNode = undefined
    @el.value = ""
    @state = @creating
    
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

computeSelfLinkPath = (d) ->
  r = 25 # linkDistance / 2
  [x, y] = [d.source.x, d.source.y]
  [x1, y1] = [outside(d.source).x, outside(d.source).y]
  "M#{x} #{y} A #{r} #{r}, 0, 0, 0, #{x1} #{y1} A #{r} #{r}, 0, 0, 0, #{x} #{y}"

tick = ->
  [selfLinks, otherLinks] = _(links).partition (its) -> its.source is its.target
  line = svg.selectAll("g.link").data(otherLinks)
  line.selectAll("line")
    .attr("x1", (d) -> d.source.x)
    .attr("y1", (d) -> d.source.y)
    .attr("x2", (d) -> d.target.x)
    .attr("y2", (d) -> d.target.y)
  line.selectAll("text")
    .attr("x", (d) -> midpoint(d).x)
    .attr("y", (d) -> midpoint(d).y)
    .text((d) -> d.linknode?.text)
    .style("fill", "#000")

  selflink = svg.selectAll("g.selflink").data(selfLinks)
  selflink.selectAll("text")
    .text((d) -> d.linknode?.text)
    .attr("x", (d) -> outside(d.source).x)
    .attr("y", (d) -> outside(d.source).y)
    .style("fill", "#000")
  selflink.selectAll("path")
    .attr("d", computeSelfLinkPath)
    .style("fill", "none")

  svg.selectAll("text.pointnode").data(pointnodes())
    .attr("x", (d) -> d.x)
    .attr("y", (d) -> d.y)
    .text((d) -> d.text)
    .style("fill", (d) ->
      switch d
        when fsm.source
          "#d00"
        when fsm.target
          "#0dd"
        else
          "#000"
    )
  
restart = ->
  [selfLinks, otherLinks] = _(links).partition (its) -> its.source is its.target
  svg.selectAll("g.link").data(otherLinks).exit().remove()
  link = svg.selectAll("g.link").data(otherLinks)
    .enter()
    .append("g")
    .attr("class", "link")
  link.append("line")
  link.append("text")
    .attr("class", "linknode")

  svg.selectAll("g.selflink").data(selfLinks).exit().remove()
  selflink = svg.selectAll("g.selflink").data(selfLinks)
    .enter()
    .append("g")
    .attr("class", "selflink")
  selflink.append("path")
  selflink.append("text")
    .attr("class", "linknode")
  
  labels = svg.selectAll("text.pointnode").data(pointnodes())
  labels.enter().append("text")
    .attr("class", "pointnode")
    .text((d) -> d.text)
    .on "click", fsm.edit.bind(fsm)
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
