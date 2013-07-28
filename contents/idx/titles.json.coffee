_ = require 'underscore'
w = require 'widx'
c = contents

_.map (w.flatfiles [c.about, c.blog, c.projects]), (art) ->
  title: art.title
  url:   art.url

