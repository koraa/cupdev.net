module.exports = (env, callback) ->
  class CDataPlugin extends env.ContentPlugin
    constructor: (@filepath) ->
    getFilename: ->
      @filepath.relative.replace /\.coffee$/, ''

    getView: ->
      return (env, locals, contents, templates, callback) ->
        try
          d = require @filepath.full
          t = JSON.stringify d
          t='' if !t # Default case

          callback null, new Buffer t
        catch er
          callback er

  CDataPlugin.fromFile = (filepath, callback) ->
    callback null,
      new CDataPlugin filepath

  env.registerContentPlugin 'data', '**/*.json.coffee', CDataPlugin
  callback()
