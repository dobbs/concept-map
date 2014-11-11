graphMethods =
  add: (item) ->
    return if @seen[item.uuid()]?
    @seen[item.uuid()] = true
    if item.midpoint?
      @add(item.source)
      @add(item.target)
      @add(item.annotation) if item.annotation?
    @all.push(item)
    @signal.changed("add", item)
    @
  onChange: (listener) -> @signal.on "changed", listener
  nodes: -> _(@all).filter (item) -> !item.midpoint?
  links: -> _(@all).filter (item) -> item.midpoint?

@createGraph = ->
  _.extend Object.create(graphMethods),
    seen: {}
    all: []
    signal: d3.dispatch("changed")