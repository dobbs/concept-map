RETURN = 13
LEFTARROW = 37
UPARROW = 38
RIGHTARROW = 39
DOWNARROW = 40
ESC = 27
CONTROL = 17
SHIFT = 16
OPTION = 18
COMMAND = 91

class KeyboardFsm
  constructor: (selection) ->
    @selection = selection
    @el = @selection.node()
    @state = @idling
    @selection.on "keyup", => @keyup()
  keyup: ->
    @keyCode = d3.event.keyCode
    @key = String.fromCharCode(@keyCode)
    @state()
    restart()
  focus: -> @el.focus()
  idling: ->
    switch @keyCode
      when ESC
        @state = @beginChoosingSource
        @state()
      else
        if /\w/.test @key
          @state = @createAndBeginLabeling
          @state()
  createAndBeginLabeling: ->
    @nodeToLabel = null #createPointNode @el.value
    @state = @labeling
  labeling: ->
    switch @keyCode
      # when ESC
      #   @state = @beginLinking
      #   @state()
      when RETURN
        @state = @cleanupLinking
        return @state()
      else
        @nodeToLabel.text = @el.value
  beginChoosingSource: ->
    if @source is undefined
      @source = null # pointnodes()[0]
    @nodeToLabel = @source
    @el.value = @nodeToLabel.text
    @sourceIndex = @source.index
    @target = undefined
    @targetIndex = undefined
    @currentLink = undefined
    @cancelFn = -> null
    @state = @choosingSource
  choosingSource: ->
    switch @keyCode
      when ESC
        @state = @cancelLinking
        return @state()
      when RETURN
        @state = @beginLinking
        return @state()
      when LEFTARROW, UPARROW
        @sourceIndex -= 1
      when RIGHTARROW, DOWNARROW
        @sourceIndex += 1
      else
        if /\w/.test @key
          @state = @labeling
          return @state()
    if @sourceIndex < 0
      @sourceIndex = nodes.length - 1
    else if @sourceIndex == nodes.length
      @sourceIndex = 0
    @source = null # nodes[@sourceIndex]
    @nodeToLabel = @source
    @el.value = @nodeToLabel.text
  beginLinking: ->
    if @target is undefined
      @target = @source
    @targetIndex = @target.index
    @currentLink = null # createLink(@source, @target, null)
    @cancelFn = ->
      links.pop()
      @cancelFn = -> null
    @state = @choosingTarget
  choosingTarget: ->
    switch @keyCode
      when ESC
        @state = @cancelLinking
        return @state()
      when RETURN
        @state = @beginLabelingLink
        return @state()
      when LEFTARROW, UPARROW
        @targetIndex -= 1
      when RIGHTARROW, DOWNARROW
        @targetIndex += 1
    if @targetIndex < 0
      @targetIndex = nodes.length - 1
    else if @targetIndex == nodes.length
      @targetIndex = 0
    @target = nodes[@targetIndex]
    @currentLink.target = @target
  cancelLinking: ->
    if _(@cancelFn).isFunction()
      @cancelFn()
    @state = @cleanupLinking
    @state()
  beginLabelingLink: ->
    @el.value = ""
    linknode = null # createLinkNode(@currentLink, calculators)
    @currentLink.linknode = linknode
    @state = @labelingLink
  labelingLink: ->
    switch @keyCode
      when RETURN
        @state = @cleanupLinking
        @state()
      else
        @currentLink.linknode.text = @el.value
  cleanupLinking: ->
    @source = undefined
    @target = undefined
    @sourceIndex = undefined
    @targetIndex = undefined
    @currentLink = undefined
    @nodeToLabel = undefined
    @el.value = ""
    @cancelFn = -> null
    @state = @idling
