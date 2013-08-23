$ = require 'jquery-browserify'
_ = require 'underscore'

#
# The Data cache
CACHE={}

#
# A dict containing list of assets/their urls
ASSETS =
  cats: "/idx/cats.json"
  tags: "/idx/tags.json"
  titles: "/idx/titles.json"
  words: "/idx/words.json"

#
# Get the objetc at the given URL
# If the object is saved in the cache, return this one
getc = (url, callb) ->
  if CACHE[url]
    callb CACHE[url]
    return

  $.get url, (dat) ->
    CACHE[url] = dat
    callb dat

getasset = (name, callb) ->
  url = ASSETS[name]
  url = url if !url
  getc url, callb

module.exports = getasset
module.exports.getc = getc
module.exports.ASSETS = ASSETS
module.exports.CACHE  = CACHE

