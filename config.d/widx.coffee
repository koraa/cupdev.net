_  = require 'underscore'
_s = require 'underscore.string'

P = (a...) ->
  console.log a...
  a[0]

rev = (ar) ->
  _.times ar.length, (i) ->
    ar[ar.length - 1 - i]

embed = (cnt) ->
  x= _.values cnt
  x= _.sortBy x, (art) -> art.date
  x= rev x


exports._ = _
exports._s = _s
exports.embed = embed
exports.rev = rev
