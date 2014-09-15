# ====== Module Dependencies ========

fs    = require 'fs'
path  = require 'path'
vm    = require 'vm'



# ======== Helper Functions =========

# Parses the stack trace to figure out the path to the caller file. This is
# necessary to resolve relative module paths in other files.
getCallerFile = ->
  try
    err = new Error()
    Error.prepareStackTrace = (err, stack) -> return stack
    currentfile = err.stack.shift().getFileName()
    while err.stack.length
      callerfile = err.stack.shift().getFileName()
      if currentfile != callerfile then return callerfile
  catch err
    return undefined


# Resolves the path to the passed module.
resolve = (module) ->
  base = path.dirname getCallerFile()
  modulePath = path.resolve base, module
  require.resolve modulePath


# Mocked require function.
_require = (module) ->
  if module.charAt(0) != '.' then return require module
  require path



# ========= Module Classes ==========

class Testability

  constructor: ->
    @_mocks = {}


  # Loads the passed module and mock dependencies. Mock dependencies loaded
  # in a call to `load` will be given precedence over the same module path
  # loaded globally via `mock()` or `mocks()`.
  require: (module, mocks) ->
    filename = resolve module
    dirname = path.dirname filename
    exports = {}
    context = vm.createContext {
      require: (mod) =>
        @_resolveMock(mod, mocks) || _require path.resolve(dirname, mod)
      console: console
      module:
        exports: exports
      exports: exports
      __filename: filename
      __dirname: dirname
    }
    vm.runInNewContext fs.readFileSync(context.__filename), context
    context.module.exports


  # Registers a single mock module.
  replace: (module, mock) ->
    @_mocks[module] = mock
    return @


  # Clears all registered mock modules.
  restoreAll: ->
    @_mocks = {}


  # Resolves whitespace separated mock module paths.
  _resolveMock: (module, scoped) ->
    check = (struct) ->
      for paths, mock of struct
        ps = paths.split /[\s,\|]+/
        for p in ps
          if module is p then return mock
      return false
    return check(scoped || {}) || check(@_mocks)



# ========= Module Exports ==========

# Export a single instance of Testability.
module.exports = new Testability()
