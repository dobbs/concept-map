keyMethods =
  isWord: ->
    that = @
    !_.any([
        @isAlt
        @isReturn
        @isArrowleft
        @isArrowup
        @isArrowright
        @isArrowdown
        @isEsc
        @isControl
        @isShift
        @isCommand
      ], (fn) -> fn.call(that))
  isAlt: -> @keyCode is 18
  isReturn: -> @keyCode is 13
  isArrow: ->
    that = @
    _.any([
      @isArrowleft
      @isArrowup
      @isArrowright
      @isArrowdown
    ], (fn) -> fn.call(that))
  isArrowleft: -> @keyCode is 37
  isArrowup: -> @keyCode is 38
  isArrowright: -> @keyCode is 39
  isArrowdown: -> @keyCode is 40
  isEsc: -> @keyCode is 27
  isControl: -> @keyCode is 17
  isShift: -> @keyCode is 16
  isOption: -> @keyCode is 18
  isCommand: -> @keyCode is 91

@createKey = (event) ->
  _.extend Object.create(keyMethods),
    keyCode: event.keyCode
