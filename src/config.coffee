"use strict"

path = require "path"
fs = require "fs"

testemSimple = require "mimosa-testem-simple"

exports.defaults = ->
  defaults = testemSimple.defaults()

  defaults.testemRequire =
    executeDuringBuild: true
    executeDuringWatch: true
    safeAssets: []
    specConvention: /[_-](spec|test)\.js$/
    assetFolder:".mimosa/testemRequire"
    testemConfig:
      "launch_in_dev": ["Firefox", "Chrome"]
      "launch_in_ci": ["PhantomJS"]
    mochaSetup:
      ui: 'bdd'
    requireConfig: null

  defaults

exports.placeholder = ->
  testemSimple.placeholder().replace("testem.json", ".mimosa/testemRequire/testem.json") +
  """
  \t

    testemRequire:                  # Configuration for the testem-require module
      executeDuringBuild            # If true the tests will get executed during build.
      executeDuringWatch            # If true the tests will get executed during watch with each file change.
      specConvention: /[_-](spec|test)\.js$/ # Convention for how test specs are named
      assetFolder: ".mimosa/testemRequire"        # Path from the root of the project to the folder that will
                                    # contain all the testing assets that the testemRequire
                                    # module maintains and writes. If the folder does not exist
                                    # it will be created.
      safeAssets: []                # An array of file names testem-require will not overwrite.
                                    # By default testem-require overwrites any file it outputs.
                                    # So, for instance, if you have a specific version of
                                    # "mocha.js" you need to use, this setting should be ["mocha.js"]
      testemConfig:                 # Pass through values for the testem.json configuration.
                                    # The module will write the testem.json for you
        "launch_in_dev": ["Firefox", "Chrome"] # In dev mode launches in Firefox and Chrome
        "launch_in_ci": ["PhantomJS"]          # In CI mode uses PhantomJS (must be installed)
      mochaSetup:                   # Setup for Mocha
        ui : 'bdd'                  # Mocha is set to bdd mode by default
      requireConfig: {}             # RequireJS configuration. By default the mimosa-require
                                    # module is used by mimosa-testem-require to derive a
                                    # requirejs config.  But if that derived config isn't right
                                    # a config can be pasted here.

  """

exports.validate = (config, validators) ->

  errors = []

  # testem-require wraps testem-simple, need to validate both
  # can't just call testemsimple validate because config file
  # might not exist and that is ok
  if validators.ifExistsIsObject(errors, "testemSimple config", config.testemSimple)
    validators.ifExistsIsNumber(errors, "testemSimple.port", config.testemSimple.port)
    validators.ifExistsIsString(errors, "testemSimple.configFile", config.testemSimple.configFile)

    if config.testemSimple.watch?
      if Array.isArray(config.testemSimple.watch)
        newFolders = []
        for folder in config.testemSimple.watch
          if typeof folder is "string"
            newFolderPath = validators.determinePath folder, config.root
            if fs.existsSync newFolderPath
              newFolders.push newFolderPath
          else
            errors.push "testemSimple.watch must be an array of strings."
        config.testemSimple.watch =  newFolders
      else
        errors.push "testemSimple.watch must be an array."

    validators.ifExistsFileExcludeWithRegexAndString(errors, "testemSimple.exclude", config.testemSimple, config.root)


  if validators.ifExistsIsObject(errors, "testemRequire config", config.testemRequire)
    validators.ifExistsIsBoolean(errors, "testemRequire.executeDuringBuild", config.testemRequire.executeDuringBuild)
    validators.ifExistsIsBoolean(errors, "testemRequire.executeDuringWatch", config.testemRequire.executeDuringWatch)
    if validators.ifExistsIsString(errors, "testemRequire.assetFolder", config.testemRequire.assetFolder)
      config.testemRequire.assetFolderFull = path.join config.root, config.testemRequire.assetFolder
    validators.ifExistsIsObject(errors, "testemRequire.testemConfig", config.testemRequire.testemConfig)
    validators.ifExistsIsObject(errors, "testemRequire.mochaSetup", config.testemRequire.mochaSetup)
    validators.ifExistsIsObject(errors, "testemRequire.requireConfig", config.testemRequire.requireConfig)
    validators.ifExistsIsArrayOfStrings(errors, "testemRequire.safeAssets", config.testemRequire.safeAssets)

    config.testemSimple.configFile = path.join config.testemRequire.assetFolderFull, "testem.json"

  errors
