#
# Simplify async programming by automatically
# handling errors.
#
# This does not really look like a simplification,
# because it's so HUGE.
# But because you have to do so much error handling with async
# functions it comes in pretty handy.
#
# In short terms: This function automatically handles errors thrown
# by your function and async-style errors thrown by subcalls
# automagically by passing them to the callback.
# The callback itself is stripped of its error argument.
# A next-to-last argument is added, with which any 
# async-style subcalls must be modified.
#
# ## Example: ############################################
#
# The exampel below takes a filepath and a transformation function
# and returns the transformed contents to the callback while correctly
# handling errors.
# The transformator is itself async.
# 
# _  = require 'underscore'
# fs = require 'fs'
# 
# modRead = as_cerr (path, transF, $$$, cb) ->
#   if !_.isFunction transF
#     # This error will be passed to the callback 
#     throw new Error "Transformator must be a function"
# 
#     fs.readFile $$$ (cnt) ->
#     # If transF throws any errors, those will be
#     # caught too because of the modifier `$$$`
#     new_cnt = transF cnt
#     # The  collback has no err argument
#     cb new_cnt
# 
# modRead "/path/to/my/file", ((s)->s.toUpperCase()), (err, cnt) ->
#   # At this point the function behaves completele normal
#   # We have the err and the cnt argument
#   if err
#     console.log "Oh bogger, something went wrong: ", err
#     return
#   console.log "WE HAVE SOME TEXT: ", cnt
# 
# ###########################################################
#
# And here is a longer, more detailed explanation:
#
# Components:
#   CODE_FUNCTION
#     The function you are writeing.
#     The function to modify with as_cerr.
#   CERR_MODIFIER
#     as_cerr, the thing you are reading the
#     docu of right now.
#   NEW_FUNCTION
#     The function, that is the return value
#     of this CERR_MODIFIER.
#     NEW_FUNCTION is wrapped around CODE_FUNCTION,
#     NEW_FUNCTION will call CODE_FUNCTION.
#   INVOKER
#     The context that will NEW_FUNCTION
#   CODE_CALLBACK
#     The callback given to the NEW_FUNCTION,
#     the callback defined in INVOKER.
#   NEW_CALLBACK
#     The callback given to the CODE_FUNCTION.
#     It is a wrapper around the CODE_CALLBACK that
#     simply inserts a "null" argument as the first
#     argument (the error argument).
#   ASYNC_SUBCALL
#     Any async call performed by CODE_FUNCTION
#   SUBCODE_CALLBACK
#     Any callback that is given to a ASYNC_SUBCALL,
#     by the CODE_FUNCTION.
#     This __only__ includes callbacks defined inline of
#     CODE_FUNCTION.
#   SUB_MOD
#     The modifier that is tailored for each CODE_FUNCTION
#     by the CERR_MODIFIER.
#     It is given to the CODE_FUNCTION as the second to last
#     argument by the CERR_MODIFIER.
#     SUBCODE_CALLBACKs must be modified with the SUB_MOD if they
#     don't use standart error handling (async-style; first arg is error)
#   SUBHANDLER
#     The SUB_MOD has an optional second argument that can serve
#     as error hanler for errors.
#     This handler takes the error as the first argument and the 'source of the error'
#     as the second argument.
#     The source is a string from this list.
#     Errors thrown by the subhandler will be passed to the CODE_CALLBACK
#
# TODO: This is BANANAS!
# TODO: Simplify doc

# Simplify managing the state by putting it in a class
class AsCerr
  # We construct this class for every invocation
  constructor: (@CODE_FUNCTION, @CODE_CALLBACK, @ARGV) ->

  CERR_MODIFIER:
    try
      code_function argv..., @SUB_MOD, @NEW_CALLBACK
    catch e
      @ERR_HANDLER e, "CODE_FUNCTION"

  NEW_CALLBACK: (argv...) =>
    @CODE_CALLBACK null, argv...

  ERR_HANDLER = (err, loc, sub_handler) =>
      # Append current stack to stacktrace
      err.stack = err.stack \
                + "From as_cerr context: " + loc + "\n"
                + "Passed on at:\n"
                + (new Error).stack
      # No subhandler
      if !subhandler
        return \
          @CODE_CALLBACK err, null
      # We have a subhandler
      try
        subhandler err, loc
      catch e
        # Again, add all the info
        e.message = "BUZAAH! Error while handling error:" \
                  + e.message
        e.stack = e.stack \
                + "\nCaused By: #{err.name} - #{err.message}:\n#{err.stack}"
        # And finally, call the actual callback        

  SUB_MOD = (er, a...) =>
      if er
        return \
          @ERR_HANDLER er, "ASYNC_SUBCALL", handler

      try
        f a...
      catch e
        return \
          @ERR_HANDLER e, "SUBCODE_CALLBACK", handler

# We wrap the class in a modifier
cerr = (f) ->
  (argv..., cb) ->
    banana = new AsCerr f, cb, argv
    banana.CERR_MODIFIER()

### # # # # # # ########################################################
##  END OF CERR  #######################################################
### # # # # # # ########################################################

# 
# Cache-modifier for the `return value`
# for async funs.
# Optionally allows a hash-function as the
# second arg.
# The default hash functions generates the hash
# from the string representation of the first arg.
#
# INVOKE: as_cache [async function] [sync hash function]
#
# Assertations (mostly: Adhere to async standarts!):
#   1. The last argument of the function is the callback.
#      the ones before that are arbitrary.
#   2. The first argument in the callback is an error.
#
# $ as_cache 
# TODO: Use ID fun instad of x->x
cache = (f,hashr=((x)->x)) ->
  g = cerr (a..., $$$, cb) ->
    # Search a value in cache
    hav = hashr a...
    if (hav in g.as_cached)
      cb null, ret
      return

    # Not found, invoke the actual fun
    f a..., $$$ (ret...) ->
      g.as_cached[hav] = ret
      cb ret...

#
# Makes a synchronous function async.
# Callback is called immediatly.
#
make = (f) ->
  cerr (argv..., $$$, cb) ->
    cb f argv

module.exports =
  cerr:  cerr
  cache: cache
  make:  make
