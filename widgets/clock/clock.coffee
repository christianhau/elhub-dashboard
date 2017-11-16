class Dashing.Clock extends Dashing.Widget



  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    @set('date', today.toDateString())
    @set('time', @formatTime(today.getHours()) + ":" + @formatTime(today.getMinutes()) + " - Oslo")

    offset2 = $(@node).data('second-time-offset')
    if offset2
      time2 = new Date()
      time2.setTime(today.getTime()+offset2*60*60*1000)
      @set('time2', @formatTime(time2.getHours()) + ":" + @formatTime(time2.getMinutes()) + " - Delhi")

    offset3 = $(@node).data('third-time-offset')
    if offset3
      time3 = new Date()
      time3.setTime(today.getTime()+offset3*60*60*1000)
      @set('time3', @formatTime(time3.getHours()) + ":" + @formatTime(time3.getMinutes()) + ":" + @formatTime(time3.getSeconds()) + " - PST")

  formatTime: (i) ->
    if i < 10 then "0" + i else i
