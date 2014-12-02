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
  linkNextNode: ->
    target = @link.target
    nodes = @graph.nodes()
    @link.target = nodes[((if target? then target.index else 0) + 1) % nodes.length]
    antenna.linkChanged 'targetChaged', @link
  linkPrevNode: ->
    target = @link.target
    nodes = @graph.nodes()
    index = (nodes.length + (if target? then target.index else nodes.length) - 1) % nodes.length
    @link.target = nodes[index]
    antenna.linkChanged 'targetChaged', @link
  labelLink: ->
    @annotation.text = @listener.value
    antenna.nodeChanged 'updateNodeText', @annotation
  cancelLink: ->
    @graph.remove @link
    @finishLink()
  finishLink: ->
    antenna.cancelNode()
    @listener.value = ''
    @annotation = null
    @link = null

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