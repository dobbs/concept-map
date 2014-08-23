[w, h] = [400, 400]

class KeyboardFsm
  constructor: (selection) ->
    @selection = selection
    @state = @creating
    @selection.on "keyup", => @keyup()
  keyup: ->
    key = String.fromCharCode(d3.event.keyCode)
    console.log(d3.event.keyCode)
    @state.call @, key
    restart()
  focus: -> @selection.node().focus()
  edit: (d) ->
    @selection.node().value = d.text
    @currentNode = d
    @state = @labeling
  labeling: (key) ->
    if d3.event.keyCode is 13
      el = d3.event.target
      el.setSelectionRange(0, el.value.length)
      @state = @creating
    else
      @currentNode.text = @selection.node().value
  creating: (key) ->
    if /\w/.test key
      @currentNode =
        index: nodes.length
        x: Math.random() * h
        y: Math.random() * w
        text: @selection.node().value
      nodes.push(@currentNode)
      @state = @labeling
  linking: (key) ->
    @source = @currentNode
    @targetIndex ||= @currentNode.index
    switch d3.event.keyCode
      when 37, 38 #leftarrow, uparrow
        @targetIndex -= 1
      when 39, 40 #rightarrow, downarrow
        @targetIndex += 1
    @targetIndex = @targetIndex % nodes.length
    @target = nodes[@targetIndex]

nodes = if localStorage.nodes then JSON.parse(localStorage.nodes) else []
links = if localStorage.links then JSON.parse(localStorage.links) else []

@saveGraph = ->
  localStorage.nodes = JSON.stringify(nodes)
  localStorage.links = JSON.stringify(links)

force = d3.layout.force()
  .charge(-80)
  .linkDistance(25)
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
  svg.selectAll("line.link")
    .data(links)
    .enter().insert("line", "text.node")
    .attr("class", "link")
  svg.selectAll("text.node")
    .data(nodes)
    .enter().insert("text")
    .attr("class", "node")
    .style("fill", (d) ->
      switch d
        when fsm.source
          "#d00"
        when fsm.target
          "#0d0"
        else
          "#000"
    )
    .text((d) -> d.text)
    .call(force.drag)
  fsm.focus()
  force.start()

force.on "tick", ->
  svg.selectAll("line.link")
    .attr("x1", (d) -> d.source.x)
    .attr("y1", (d) -> d.source.y)
    .attr("x2", (d) -> d.target.x)
    .attr("y2", (d) -> d.target.y)

  svg.selectAll("text.node")
    .attr("x", (d) -> d.x)
    .attr("y", (d) -> d.y)
    .text((d) -> d.text)
    .style("fill", (d) ->
      switch d
        when fsm.source
          "#d00"
        when fsm.target
          "#0d0"
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
