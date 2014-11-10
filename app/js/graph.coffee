graphPrototype =
  add: (item) ->
    if @seen[item.uuid()]?
      return
    if item.midpoint?
      @add(item.source)
      @add(item.target)
    @seen[item.uuid()] = true
    @all.push(item)
    @signal.changed("add", item)
    @
  onChange: (listener) -> @signal.on "changed", listener
  nodes: -> _(@all).filter (item) => !item.midpoint?
  links: -> _(@all).filter (item) => item.midpoint?

@createGraph = ->
  graph = Object.create(graphPrototype)
  _.extend graph,
    seen: {}
    all: []
    signal: d3.dispatch("changed")