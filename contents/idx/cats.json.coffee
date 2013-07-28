_ = require 'underscore'
w = require 'widx'
c = contents

_.concat = (a...) ->
  [].concat a...

prefixes =
  about: w.flatfiles c.about
  blog: w.flatfiles c.blog
  projects: w.flatfiles c.projects

# TO format:
# [{cat: [$root, $1level, $2level], url: $url},...]
x_= for pre__,files of prefixes
  pre= pre__.toLocaleLowerCase()
  pre= w.tokenize pre__, '/'

  _.map files, (f) ->
    cat: _.concat \
      pre,
      w.tokenize f.metadata.category, '/'
    url: f.url

# Now make it shallow
x_= _.flatten x_, true

data = {}
_.each x_, (e) ->
  ar = w.tree_set data, (_.concat e.cat, '__urls'), []
  ar.push e.url

data
