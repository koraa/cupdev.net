path   = require 'path'
fs     = require 'fs'
_      = require 'underscore'
_s     = require 'underscore.string'
svgo   = new (require 'svgo')
Canvas = require 'canvas'
canvg  = require 'canvg'
w      = require 'widx'
less   = require 'less'

module.exports = (env, bigCallbackTheory) ->

  # TODO: Own Lib
  renderSVG = (svg, width, height, callb) ->
    can = new Canvas width, height
    canvg can, svg,
      renderCallback: ->
        can.toBuffer callb

  ###################################
  
  class HubeDubDub extends env.ContentPlugin
    constructor: (@filepath, @hub)->

    # Overwrite to implement the actual transform.
    # Just gets the contents.
    nocache_transform: (cnt, callb) -> # Just gets the plain contents of the SVG
      callb new Error "You no implement nocache_transform. Moron."
    
    # Called internally top get the contents (no additional info, still async)
    transform: (callb) ->
      if @cache
        callb null, @cache
        return

      tis = @
      @hub.getCnt (err, cnt) ->
        if err
          callb err, null
          return
        # FINALLY, transform
        tis.nocache_transform cnt, callb

    # Called by wintersmith to get the contents
    getView: ->
      tis = @ # Just in case, avoid fu with scopes
      (env, locals, contents, templates, callback) ->
        tis.transform (err, cnt) ->
          callback err, Buffer cnt

  ##########################################

  class SVGPluginHUB
    constructor: (@filepath)->
      @toSVG  = new SVGPluginSVG @filepath, @
      @toPNG  = new SVGPluginPNG @filepath, @
      @plugins = [@toSVG, @toPNG]
      
      # Init less params
      @writeLessParams()

    getCnt: (callb) ->
      if @cache
        callb null, @cache
        return
      fs.readFile @filepath.full, (err, cnt) ->
        if err
          callb err, null
          return
        @cache = String cnt
        callb null, @cache

    getLessParams: (cnt, callb) ->
      tis=@
      @toSVG.getInfo (er, info) -> # TODO: Implement a 'hope' function for less 'if er's
        if er
          callb er, null
          return

        basen = path.basename \
          tis.filepath.relative.replace /\.svg$/, ''

        callb null, w.Dic \
          "img_#{basen}",       ( "/" + tis.toSVG.getFilename() ),
          "img_#{basen}_alt",   ( "/" + tis.toPNG.getFilename() ),
          "img_#{basen}_w",     ( new less.tree.Dimension info.width ),
          "img_#{basen}_h",     ( new less.tree.Dimension info.height ),
          "img_#{basen}_ratio", ( new less.tree.Dimension (info.height/info.width) )

    # Store the variables
    writeLessParams: (cnt, callb) ->
      @getLessParams cnt, (er, params) ->
        if er
          callb er, null
          return
        w.P "WRITE LESS PARAMS: ", params

        _.extend (w.tree_mknode env, 'config/less/vars'), params

  ####################################

  class SVGPluginSVG extends HubeDubDub
    getFilename: -> @filepath.relative
    nocache_transform: (cnt, callb) ->
      svgo.optimize cnt, (res) ->
        @info = res.info
        callb null, res.data

    getInfo: (callb) -> # The info is actually extracted by svgo in the transformation
      if @info
        callb @info
        return
      @transform (err, svg)->
        callb err, @info

  ####################################

  class SVGPluginPNG extends HubeDubDub
    getFilename: -> @filepath.relative.replace /\.svg$/, '.png'
    nocache_transform: (cnt, callb) ->
      tis = @
      tis.hub.toSVG.transform (er, svg) -> # TODO: Paralellize
        if er                  # TODO: Implement a 'hope' function for less 'if er's
          callb er, null
          return
        tis.hub.toSVG.getInfo (er, info) ->
          if er
            callb er, null
            return
          renderSVG svg, info.width, info.height, (er, buf) ->
            if er
              callb er, null
              return
            callb null, buf

  #####################################
  
  # (sync both plugins by cacheing the hubs/their paths)
  hubFromFile = _.memoize                      \
    ((filepath) -> new SVGPluginHUB filepath), \
    ((filepath) -> filepath.relative) # Hashing F for memoize

  # !! the order of plugins should prpbably stay the same !!
  env.registerContentPlugin 'data', '**/*.svg',
    fromFile: (filepath, callb) ->
      callb null, (hubFromFile filepath).toSVG

  env.registerGenerator "data", (data, callb) ->
    r= data
    r= w.flatfiles r
    r= _.filter r, (file) ->
      /\.svg$/.test (w.traverse file, 'filepath/full')
    r= _.map r, (file) ->
      hubFromFile file.filepath

    tree = {}
    _.each r, (hub) ->
      _.each hub.plugins, (plugin) ->
        w.tree_set tree, plugin.getFilename(), plugin
    
    callb null, tree

  ##########################################

  bigCallbackTheory()
