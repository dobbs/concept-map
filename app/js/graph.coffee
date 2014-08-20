[w, h] = [400, 400]

force = d3.layout.force()
  .charge(-80)
  .linkDistance(25)
  .size([w, h]);

nodes = force.nodes()
links = force.links()

svg = d3.select("body").append("svg")
  .attr("width", w)
  .attr("height", h)

keyboardListener = d3.select("body").append("input")
  .attr("id", "keyboardListener")
  .attr("type", "text")
  .attr("size", 75)
  .attr("autofocus", 1)

restart = ->
  svg.selectAll("line.link")
    .data(links)
    .enter().insert("line", "text.node")
    .attr("class", "link")
  svg.selectAll("text.node")
    .data(nodes)
    .enter().insert("text", "circle.cursor")
    .attr("class", "node")
    .text("unnamed")
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
    .on "click", fsm.edit.bind(fsm)

class KeyboardFsm
  constructor: (selection) ->
    @selection = selection
    @state = @creating
    @selection.on "keyup", => @keyup()
  keyup: ->
    key = String.fromCharCode(d3.event.keyCode)
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
      @currentNode.text = d3.event.target.value
  creating: (key) ->
    if /\w/.test key
      @currentNode =
        x: Math.random() * h
        y: Math.random() * w
        text: ""
      @currentNode.text = d3.event.target.value
      nodes.push(@currentNode)
      @state = @labeling
fsm = new KeyboardFsm(keyboardListener)

d3.select('body').on "click", fsm.focus.bind(fsm)
fsm.focus()
restart();

