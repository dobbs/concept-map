keyboardMethods =
  keyup: (event) -> @state(createKey event)
  changeTo: (fn) -> @state = fn; @
  forward: (key) -> @state(key)
kb = _.extend Object.create(keyboardMethods),
  state: null

idle = (key, code) -> kb.changeTo(firstalt) if key.isAlt()
firstalt = (key, code) ->
  if key.isAlt()
    kb.changeTo(ready)
    antenna.readyForEntry()
  else
    kb.changeTo(idle)

ready = (key) ->
  switch
    when key.isWord()
      kb.changeTo(createForLabeling).forward key
    when key.isArrow()
      kb.changeTo(editNode).forward key

createForLabeling = (key) ->
  antenna.createNode()
  kb.changeTo(labeling).forward key

labeling = (key) ->
  switch 
    when key.isReturn()
      antenna.finishNode()
      kb.changeTo(ready)
    when key.isAlt()
      kb.changeTo(idle)
      antenna.finishNode()
    when key.isWord()
      antenna.updateNodeText key

editNode = (key) ->
  switch
    when key.isReturn()
      kb.changeTo(ready)
    when key.isArrowleft() || key.isArrowup()
      antenna.editPrevNode()
    when key.isArrowright() || key.isArrowdown()
      antenna.editNextNode()

kb.changeTo idle
  
#usage: document.body.addEventListener('keyup', keyboard)
@keyboard = -> kb.keyup(arguments...)
