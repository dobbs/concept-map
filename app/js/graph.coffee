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
  remove: (item) ->
    return unless item && item.uuid && item.uuid() && @seen[item.uuid()]?
    return if _.any(@links(), (link) ->
      link.source.uuid() is item.uuid() ||
      link.target.uuid() is item.uuid() ||
      link.annotation?.uuid() is item.uuid()
    )
    @seen[item.uuid()] = undefined
    @all = _.reject @all, (that) -> that.uuid() is item.uuid()
    @remove(item.annotation) if item.midpoint?
    antenna.graphChanged("remove", item)
    @
  nodes: -> _(@all).filter (item) -> !item.midpoint?
  links: -> _(@all).filter (item) -> item.midpoint?

@createGraph = ->
  _.extend Object.create(graphMethods),
    seen: {}
    all: []
