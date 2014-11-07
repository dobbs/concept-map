class Graph
  constructor: (@all=[]) ->
    @seen = {}
  add: (item) ->
    if @seen[item.unique_identifier]?
      return
    if item instanceof Link
      @add(item.source)
      @add(item.target)
    @seen[item.unique_identifier] = true
    @all.push(item)
  nodes: -> _.filter(@all, (item) => item instanceof Node)
  links: -> _.filter(@all, (item) => item instanceof Link)

@Graph = Graph