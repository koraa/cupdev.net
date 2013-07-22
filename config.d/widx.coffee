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


# 
# Take a node from the ContentTree
# and check it it is a file
treefile = (n) ->
  n.__filename


#
# Traverse dict by path:
# Takes a path as array or unix-format
# and returns the element in a tree
#
traverse = (d,p) ->
  if _.isString p
    p = _.map (_s.words p, "/"), (s) -> _s.strip s

  if p.length < 1
    return d
  traverse d[_.head p], _.tail p
  
embed = (x, root) ->
  x= castarray x         # Handle non-array args x -> [x]
  x= _.map x, (e) ->     # Extract all files
    if _.isString e        # Handle string args
      e = traverse root, e
    if treefile e          # Handle Files
      return [e]
    _.values e             # Handle dirs
  x= _.flatten x, true   # Vectorize
  x= _.reject x, (e) ->  # Reject meta contents
    _.contains (tokenize e.metadata.flags), "meta"
  x= _.sortBy x, (art) -># Sort by date
    art.date
  x= _.uniq x, true      # Remove duplicates
  x= rev x

flatfiles = (x,root) ->
  x= castarray x         # Handle non-array args x -> [x]
  x= _.map x, (e) ->     # Extract all files
    if _.isString e        # Handle string args
      e = traverse root, e
    if treefile e          # Handle Files
      return [e]
    _.values e             # Handle dirs
  x= _.flatten x, true   # Vectorize

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
exports.flatfiles = flatfiles
