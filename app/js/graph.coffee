graphMethods =
  add: (item) ->
    return if @seen[item.uuid()]?
    @seen[item.uuid()] = true
    if item.midpoint?
      @add(item.source)
      @add(item.target)
      @add(item.annotation) if item.annotation?
    @all.push(item)
    antenna.graphChanged("add", item)
    @
  nodes: -> _(@all).filter (item) -> !item.midpoint?
  links: -> _(@all).filter (item) -> item.midpoint?

@createGraph = ->
  _.extend Object.create(graphMethods),
    seen: {}
    all: []
