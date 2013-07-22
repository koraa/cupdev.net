_ = require 'underscore'
w = require 'widx'
c = contents

flat= w.flatfiles [c.about, c.blog, c.projects]

dict = {}

_.each flat, (f) ->
  tags = w.tokenize f.metadata.tags # Get tags
  tags = ["none"] if tags.length < 1

  _.each tags, (t) ->
    dict[t]=[] if !dict[t] # Default entry
    dict[t].push f.url

dict
