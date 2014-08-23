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
  beginLabeling: ->
    @currentNode =
      index: nodes.length
      x: Math.random() * h
      y: Math.random() * w
      text: @selection.node().value
    nodes.push(@currentNode)
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
      @currentNode = nodes[0]
    @source = @currentNode
    @target = @currentNode
    @targetIndex = @currentNode.index
    @currentLink =
      source: @source
      target: @target
    links.push(@currentLink)
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
        @currentLink.label = @el.value
  cleanupLinking: ->
    @source = undefined
    @target = undefined
    @targetIndex = undefined
    @currentLink = undefined
    @state = @creating
    
nodes = if localStorage.nodes then JSON.parse(localStorage.nodes) else []
links = if localStorage.links then JSON.parse(localStorage.links) else []

@saveGraph = ->
  localStorage.nodes = JSON.stringify(nodes)
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

restart = ->
  link = svg.selectAll("g.link").data(links)
    .enter()
    .append("g")
    .attr("class", "link")
  link.append("line")
  link.append("text")
    .attr("class", "annotation")
    .text((d)->d.label)

  svg.selectAll("g.link").selectAll("text.annotation").data(links)
    .text((d)->d.label)

  svg.selectAll("g.link").data(links).exit().remove()
  
  svg.selectAll("text.node")
    .data(nodes)
    .enter().insert("text")
    .attr("class", "node")
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
  fsm.focus()
  force.start()

force.on "tick", ->
  lines = svg.selectAll("g.link")
  lines.selectAll("line")
    .attr("x1", (d) -> d.source.x)
    .attr("y1", (d) -> d.source.y)
    .attr("x2", (d) -> d.target.x)
    .attr("y2", (d) -> d.target.y)
  lines.selectAll("text")
    .attr("x", (d) -> d.source.x + (d.target.x - d.source.x) / 2 )
    .attr("y", (d) -> d.source.y + (d.target.y - d.source.y) / 2 )
    .style("fill", "#000")

  svg.selectAll("text.node")
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
    .on "click", fsm.edit.bind(fsm)

d3.select('body').on "click", fsm.focus.bind(fsm)
fsm.focus()
restart();

@nodes = nodes
@links = links
@fsm = fsm
