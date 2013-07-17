_  = require 'underscore'
_s = require 'underscore.string'

P = (a...) ->
  console.log a...
  a[0]

rev = (ar) ->
  _.times ar.length, (i) ->
    ar[ar.length - 1 - i]

castarray = (x) ->
  if _.isArray x
    x
  else
    r = _.toArray x
    if r
      r
    else
      [x]

tokenize = (l) ->
  if _.isArray l
    a = l
  else if _.isString l
    return wordlist l
  else
    a = castarray l

  _.map a, (x) -> _s.strip x

embed = (cnt) ->
  x= _.values cnt
  x= _.reject x, (e) ->
    _.contains (tokenize e.metadata.flags), "meta"
  x= _.sortBy x, (art) -> art.date
  x= rev x

wordlist = (x) ->
  x= _s.words x, /,/
  x= _.map x, (x) -> _s.strip x
  x= _.filter x, (s) -> s

treesec = (x) ->
  x= _s.words x, /\//
  x= _.map x, (x) -> _s.strip x
  x= _.filter x, (s)->s
  x= _.times x.length, (i) ->
    name: x[i]
    path: _s.join "/", x[..i]
    depth: i

exports._ = _
exports._s = _s
exports.embed = embed
exports.wordlist = wordlist
exports.treesec = treesec
exports.rev = rev
