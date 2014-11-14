linkEditorMethods =
  updateElementAttributes: ->
    @fields.attr('value', (d) -> d.get())
    @readOnlyFields.text((d) -> d.get())
  edit: (link) ->
    @that.link = link
    @updateElementAttributes()

@linkEditor = (link) ->
  that =
    link: link
  editableData = [
    {get: (-> that.link.distance()), set: (distance) -> that.link.storedDistance = distance}
  ]
  readableData = [
    {get: -> that.link.source.text}
    {get: -> that.link.target.text}
    {get: -> that.link.annotation?.text}
  ]
  fields = d3.selectAll('[data-id=link-editor] input').data(editableData).each (d) ->
    input = @
    d3.select(input).on 'change', ->
      d.set input.value
      antenna.linkChanged that.link, input.dataset.id, input.value
  readOnlyFields = d3.selectAll('[data-id=link-editor] span').data(readableData)
  _.extend Object.create(linkEditorMethods),
    fields: fields
    readOnlyFields: readOnlyFields
    that: that
