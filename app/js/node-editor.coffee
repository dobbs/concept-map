nodeEditorMethods =
  updateElementAttributes: -> @fields.attr('value', (d) -> d.get())
  edit: (newNode) ->
    @that.node.style = undefined if @that.node?
    @that.node = newNode
    @that.node.style = 'active'
    antenna.nodeChanged @that.node, 'style', 'active'
    @updateElementAttributes()

@nodeEditor = ->
  that =
    node: null
  theData = -> [
    {get: (-> that.node.text)         , set: (value) -> that.node.text = value || ''}
    {get: (-> that.node.charge())     , set: (value) -> that.node.storedCharge = parseInt(value)}
    {get: (-> that.node.position().x) , set: (value) -> that.node.x = parseFloat(value)}
    {get: (-> that.node.position().y) , set: (value) -> that.node.y = parseFloat(value)}
  ]
  fields = d3.selectAll("[data-id=node-editor] input").data(theData).each (d) ->
    input = @
    d3.select(input).on 'change', ->
      d.set input.value
      antenna.nodeChanged that.node, input.dataset.id, input.value
  ne = _.extend Object.create(nodeEditorMethods),
    fields: fields
    that: that
  antenna.on 'editNode', (node) -> ne.edit(node)
  ne