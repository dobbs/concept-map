class Graph
  constructor: (@nodes=[], @links=[]) ->
  add: (node) ->
    node.index = @nodes.length
    @nodes.push(node)
  link: (sourceIndex, targetIndex, text='') ->
    source = @nodes[sourceIndex]
    target = @nodes[targetIndex]
    link = new Link(source, target, text)
    @links.push(link)
    
@Graph = Graph