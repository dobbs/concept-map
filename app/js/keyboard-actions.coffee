keyboardActionsMethods = 
  createNode: ->
    @node = createNode()
    @graph.add @node
  finishNode: ->
    @listener.value = ''
    @node = null
  updateNodeText: ->
    @node.text = @listener.value
    antenna.nodeChanged 'updateNodeText', @node
  editNextNode: ->
    nodes = @graph.nodes()
    @node = nodes[((if @node? then @node.index else 0) + 1) % nodes.length]
    antenna.editNode(@node)
  editPrevNode: ->
    nodes = @graph.nodes()
    index = (nodes.length + (if @node? then @node.index else nodes.length) - 1) % nodes.length
    @node = nodes[index]
    antenna.editNode(@node)
  createLink: ->
    @annotation = createNode()
    @link = createLink(@node, @node, @annotation)
    @graph.add @link
  cancelLink: ->
    @graph.remove @link
    @finishLink()
  finishLink: ->
    antenna.cancelNode()

@keyboardActions = (listener, graph) ->
  obj = _.extend Object.create(keyboardActionsMethods),
    graph: graph
    listener: listener
    node: null
    link: null
    annotation: null
  antenna.on 'readyForEntry', -> obj.listener.focus()
  for eventName, value of obj when _.isFunction(value)
    do (eventName, value) -> 
      antenna.on eventName, -> obj[eventName]()
  obj