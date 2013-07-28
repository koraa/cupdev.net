_ = require 'underscore'
_s = require 'underscore.string'
w = require 'widx'
tt = require 'html-to-text'
c = contents

_.concat = (a...) ->
  [].concat a...

arts = w.flatfiles [c.about, c.blog, c.projects]

d = {}
_.each arts, (a) ->
  tok= tt.fromString a.html
  tok= _s.words tok, /\W/
  tok= _.filter tok, (x) -> x

  # Count each token
  dsub = {}
  _.each tok, (t) ->
    dsub[t]=0 if !dsub[t]
    dsub[t]++

  # Push counts/tokens to the data
  for t, n of dsub
    d[t]=[] if !d[t]
    d[t].push
      url: a.url
      cnt: n

# Finally sort the lists of occurences by frequency
for tok,occ of d
  d[tok] = _.sortBy occ, (oc) ->
    # Frequency, also reverse
    - oc.cnt

# And return the data
d
