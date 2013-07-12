_ = require 'underscore'
_.mixin require 'underscore.string'

P = (a...) ->
  console.log a...
  a[0]

embed = (cnt) ->
  _.reverse \
    _.sortBy ( d for f,d of cnt ), 'date'

gettags = (post) ->


exports.embed = embed
