class Link
  constructor: (@source, @target, @annotation) ->
  midpoint: ->
    x: @target.x + (@source.x - @target.x) / 2
    y: @target.y + (@source.y - @target.y) / 2

@Link = Link