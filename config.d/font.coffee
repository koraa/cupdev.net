path   = require 'path'
fs     = require 'fs'
_      = require 'underscore'
_s     = require 'underscore.string'
w      = require 'widx'
less   = require 'less'
temp   = require 'temp'

module.exports = (env, bigCallbackTheory) ->

  ##########################################

  class FontPluginHUB
    constructor: (@filepath, @fontname)->
      # Convenience alias for the filepath
      @fp  = @filepath
      @rel = @fp.relative
      @abs = @fp.absolute

      @plugins = [@toSVG, @toPNG]
      

    getTempdir: (cb) -> # TODO: We 
      if @tmpDirCache
        cb null, @tmpDirCache
        return
      tmp.mkdir "wintersmith-cupdev-fontcustom", (er, pth) ->
        if err
          cb er, pth
          return
        @tmpDirCache = pth
        cb
        

  ####################################

  class FileBufPlugin extends env.ContentPlugin
    constructor: (@filepath, @buf) ->
    getFilename: -> @filepath.relative
    getView: ->
      tis=@
      (env,locals,templates,cb) ->
        cb null, tis.buf


  #####################################
  
  env.registerGenerator "dat", (data, callb) ->
    # Find all the font dirs
    # In: tree
    # Out: List of paths, where each path is a list of keys 
    fntz= w.flatfolders data
    fntz= _.keys fntz
    fntz= _.filter fntz, (p) -> /[^/]\.font/i
    fntz= _.reject fntz, _.isEmpty
    fntz= _.map fntz, (ssp) -> w.tokenize ssp, '/'
    

    # We strip the font dirs from the content tree here,
    # because we need to remove something, which is
    # not supported by wintersmith itself
    _.each fntz, (p) ->
      w.tree_del data, p

    # Now we generate the plugin tree
    # (Write a list of [$path, $plugin],
    # write at those paths to the tree 'Tre(…)')
    tree= _.map fntz, (fp) -> # Generate all the plugin hubs from the filepaths
      new FontPluginHUB
        relative: fp # This dict is the filepath
        absolute: path.resolve "contents", (fp.join '/')
    w.P "tree => ", tree
    tree= _.map tree, (hub) ->    # Get the list of all plugins: 
      _.map hub.plugins, (plg) -> # result=[[{path:$path, val:$ContentPlugin }, ...], ...]
        path: plg.getFilename()
        val:  plg
    tree= _.flatten tree, true # Remove the unnecessary nesting
    tree= w.Tre tree          # Finally convert [$path, $value] to trees

    callb null, tree

  ##########################################
  bigCallbackTheory()
