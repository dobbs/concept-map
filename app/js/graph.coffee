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
  createPointNode: (text, x=Math.random()*h, y=Math.random()*w) ->
    pointnode =
      type: "pointnode"
      text: text
      x: x
      y: y
      uid: pointnodes.length*1000
    pointnodes.push(pointnode)
    recalculateNodes()
    pointnode
  createLinkNode: (link) ->
    linknode =
      type: "linknode"
      text: ""
      x: link.target.x + (link.source.x - link.target.x) / 2
      y: link.target.y + (link.source.y - link.target.y) / 2
      uid: linknodes.length*1000+1
    linknodes.push(linknode)
    recalculateNodes()
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
      @currentNode = pointnodes[0]
    @source = @currentNode
    @target = @currentNode
    # the following array index works by accident
    # pointnodes are always the first in the nodes array
    # and orderd by their creation.  Probably need a more
    # explicitly coupled way of holding and adjusting a
    # cursor in this of pointnodes.
    @targetIndex = Math.floor(@currentNode.uid/1000)
    @currentLink = 
      source: @source
      target: @target
    links.push(@currentLink)
    @currentLink.linknode = @createLinkNode(@currentLink)
    linknodes.push(@currentLink.linknode)
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
      @targetIndex = pointnodes.length - 1
    else if @targetIndex == pointnodes.length
      @targetIndex = 0
    @target = pointnodes[@targetIndex]
    @currentLink.target = @target
  cancelLinking: ->
    links.pop()
    @state = @cleanupLinking
    @state()
  beginLabelingLink: ->
    @el.value = ""
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
    
pointnodes = if localStorage.pointnodes then JSON.parse(localStorage.pointnodes) else []
linknodes = if localStorage.linknodes then JSON.parse(localStorage.linknodes) else []
nodes = []
recalculateNodes = ->
  nodes.length = 0
  _(nodes).extend(_.flatten([pointnodes, linknodes]))
links = if localStorage.links then JSON.parse(localStorage.links) else []

@saveGraph = ->
  localStorage.pointnodes = JSON.stringify(pointnodes)
  localStorage.linknodes = JSON.stringify(linknodes)
  localStorage.links = JSON.stringify(links)

force = d3.layout.force()
  .charge(-80)
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

tick = ->
  midpoint = (link) ->
    x: link.target.x + (link.source.x - link.target.x) / 2
    y: link.target.y + (link.source.y - link.target.y) / 2
  lines = svg.selectAll("g.link").data(links)
  lines.selectAll("line")
    .attr("x1", (d) -> d.source.x)
    .attr("y1", (d) -> d.source.y)
    .attr("x2", (d) -> d.target.x)
    .attr("y2", (d) -> d.target.y)
  lines.selectAll("text")
    .attr("x", (d) -> midpoint(d).x)
    .attr("y", (d) -> midpoint(d).y)
    .text((d) -> d.linknode.text)
    .style("fill", "#000")

  svg.selectAll("text.pointnode").data(pointnodes)
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
  link = svg.selectAll("g.link").data(links)
    .enter()
    .append("g")
    .attr("class", "link")
  line = link.append("line")
  linknode = link.append("text")
    .attr("class", "linknode")
    .text((d)->d.linknode.text)

  svg.selectAll("g.link").data(links).exit().remove()
  
  labels = svg.selectAll("text.pointnode").data(pointnodes)
  labels.enter().append("text")
    .attr("class", "pointnode")
    .style("fill", (d) ->
      switch d
        when fsm.source
          "#d00"
        when fsm.target
          "#0dd"
        else
          "#000"
    )
    .text((d) -> d.text)
    .call(force.drag)
    .on "click", fsm.edit.bind(fsm)
  tick()
  fsm.focus()
  force.start()

force.on "tick", tick

d3.select('body').on "click", fsm.focus.bind(fsm)
fsm.focus()
restart();

@nodes = nodes
@links = links
@fsm = fsm
