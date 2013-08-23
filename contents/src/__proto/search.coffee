_  = require 'underscore'
_s = require 'underscore.string'
as = require 'async'

window._s = _s

asset = require './asset.coffee'
w = require './widx.coffee'

#
# Map, but expects a nested list.
# Each sublist will be passed to the
# function as parameters.
#
# TODO: Merge with underscore?
mapply = (argvv, f) ->
  _.map argvv,(args) ->
    f args...

#
# Join multiple dicts (objects).
# The returned value is a completely new array.
#
# TODO: Merge with underscore?
joinD = (a...) ->
  _.extend {}, _.flatten a

# Map on a dictionary.
# Takes a dict and a function 'f(key, value, store)'
# where store is the target dict
# returns oneother dict.
# Each invocation of 'f' must return a dict itself.
# TODO: Merge with underscore?
mapD = (dic, f) ->
  joinD \
    mapply (_.pairs dic), f


getidx = (callb) ->
  as.parallel [
      ((c)-> asset 'cats', (a...) -> c null, a...  ), # TODO: Cache function? Use functional lib to curry
      ((c)-> asset 'tags', (a...) -> c null, a...  ),
      ((c)-> asset 'titles', (a...) -> c null, a...),
      ((c)-> asset 'words', (a...) -> c null, a... )
    ], (err, res) ->
      if err
        callb err
        return

      callb null,
        cats: res[0]
        tags: res[1]
        titles: res[2]
        words: res[3]

# TODO: Find a way to evaluate this lazyly
# TODO: Search for REGEX
# TODO: Search for 
search = (idx, query) ->
  tok= w.tokenize query, /\W/
  tok= _.map tok, (s) -> s.toLocaleLowerCase()

  # Get the levdist for every token for every dict word
  # IN:
  #   1. idx.words: 
  #     { 
  #       $str_word: [{url: $str_url, cnt: $str_freq}, ...],
  #       ...
  #     }
  #   2. tok: 
  #     [$str_token, ...]
  # OUT:
  #   [
  #     { 
  #       levdist: $int_dist, 
  #       q
  #       urls: [{url: $str_url, cnt: $str_freq}, ...]
  #     },
  #     ...
  r = mapply  (_.pairs idx.words), (word, urls) ->
    _.map tok, (t) ->
      levdist: _s.levenshtein t, word
      urls:    urls
  r= _.flatten r

  # Dump everything with a levdist>5 (for speed/sparta)
  # IN <=> OUT
  r= _.reject r,  (lpair) ->
    lpair.levdist > 2
  
  # We are going to use this function to 
  # devalue the frequency coefficient of
  # the end search-weight of a url:
  # Apply log scale to token count
  # to weight many different matches
  # stronger than many times the same
  #
  # This function is memoized because
  # log is expensive and input is often
  # going to be the same
  freqmod = _.memoize (cnt) ->
    Math.log cnt+3

  # Weight matches => DICT
  # TODO: Express as proper map/reduce
  # OUT:
  #   { 
  #     $str_url: $str_weigt,
  #     ...
  #   }
  d ={}
  _.each r, (en) ->
    value = 1/(10*en.levdist + 1) # Value of each single occurence
    _.each en.urls, (dst) ->
      d[dst.url]=0 if !d[dst.url]
      d[dst.url] += value *  (freqmod dst.cnt)
  r= d

  # Back to array, sort
  # OUT: [$str_url, $_str_cheaper_url, ...]
  r= _.pairs r
  r= _.sortBy r, (kv) -> -kv[1]
  r= _.map r, (kv) -> kv[0] # Ditch weights

# Wrapper around the actual search function:
# Get all required media first
search_wrap = (query, callb) ->
  getidx (err, idx) ->
    return callb err if err
    callb null, (search idx, query)

module.exports = search_wrap
module.exports.search_dict
module.exports.getidx = getidx

