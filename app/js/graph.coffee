graphPrototype =
  add: (item) ->
    if @seen[item.uuid()]?
      return
    if item.midpoint?
      @add(item.source)
      @add(item.target)
    @seen[item.uuid()] = true
    @all.push(item)
  nodes: -> _.filter(@all, (item) => !item.midpoint?)
  links: -> _.filter(@all, (item) => item.midpoint?)

@createGraph = ->
  graph = Object.create(graphPrototype)
  _.extend graph,
    seen: {}
    all: []
