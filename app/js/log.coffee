scrollback = []
log = d3.select('[data-id=log]')
antenna.on 'log', (message) ->
  scrollback.push(message)
  log.selectAll('p').data(scrollback)
    .enter()
    .append('p')
    .text (m) ->
      d = new Date()
      "#{d.getHours()}:#{d.getMinutes()}:#{d.getSeconds()}.#{d.getMilliseconds()} #{m}"
