_ = require 'underscore'
_.reverse = (x) ->
  x.reverse()

embed = (cnt) ->
  _.reverse \
    _.sortBy ( d for f,d of cnt ), 'date'

exports.embed = embed
