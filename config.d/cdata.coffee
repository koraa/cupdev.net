path   = require 'path'
fs     = require 'fs'
coffee = require 'coffee-script'
_      = require 'underscore'

#
# Execute a given coffescript file
# and return the result.
# The result is determined by the return (last)
# statement instad of module.exports
evfile = (f, options) ->
  options.filename = f
  code = String fs.readFileSync f
  
  # Setup sandbox
  _.extend options.sandbox, global 
  if !options.sandbox.require
    options.sandbox.require = require

  coffee.eval code, options

module.exports = (env, callback) ->
  class CDataPlugin extends env.ContentPlugin
    constructor: (@filepath) ->
    getFilename: ->
      @filepath.relative.replace /\.coffee$/, ''

    getView: ->
      return (env, locals, contents, templates, callback) ->
        try
          d = evfile @filepath.full,
            sandbox:
              contents: contents
              templates: templates
              locals: locals
          t = JSON.stringify d
          t='' if !t # Default case

          callback null, new Buffer t
        catch er
          callback er

  CDataPlugin.fromFile = (filepath, callback) ->
    callback null, new CDataPlugin filepath

  env.registerContentPlugin 'data', '**/*.json.coffee', CDataPlugin
  callback()
