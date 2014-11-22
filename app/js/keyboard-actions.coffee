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

@keyboardActions = (listener, graph) ->
  obj = _.extend Object.create(keyboardActionsMethods),
    graph: graph
    listener: listener
    node: null
  antenna.on 'readyForEntry', -> obj.listener.focus()
  antenna.on 'createNode', -> obj.createNode()
  antenna.on 'finishNode', -> obj.finishNode()
  antenna.on 'updateNodeText', -> obj.updateNodeText()
  antenna.on 'editNextNode', -> obj.editNextNode()
  antenna.on 'editPrevNode', -> obj.editPrevNode()
  obj