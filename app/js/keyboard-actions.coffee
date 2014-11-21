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

@keyboardActions = (listener, graph) ->
  obj = _.extend Object.create(keyboardActionsMethods),
    graph: graph
    listener: listener
    node: null
  antenna.on 'readyForEntry', -> obj.listener.focus()
  antenna.on 'createNode', -> obj.createNode()
  antenna.on 'finishNode', -> obj.finishNode()
  antenna.on 'updateNodeText', -> obj.updateNodeText()
  obj