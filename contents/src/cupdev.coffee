$ = require 'jquery-browserify'
_ = require 'underscore'
#search = require './__proto/search.coffee'

require 'bootstrap/js/transition'
require 'bootstrap/js/collapse'

P = (a...) ->
  console.log a...
  return _.last a

$(document).ready ->
  _.map ($ '.date'), (e__) ->
    try
      e = $ e__
      ds = e.html()
      e.html (new Date e.html())
        .toLocaleString()

  _.map ($ 'h1, h2, h3, h4, h5, h6'), (e__) ->
    e = $ e__
    e.wrap '<div class="ornwrap">'

window.P  = P
window._  = _
window.$  = $
window.search = search

