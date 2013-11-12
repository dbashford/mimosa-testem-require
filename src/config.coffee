"use strict"

path = require "path"

exports.defaults = ->
  testemSimple:
    configFile:".mimosa/testem.json"
  testemRequire:
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

exports.placeholder = ->
  """
  \t

    # testemRequire:                  # Configuration for the testem-require module
      # executeDuringBuild            # If true the tests will get executed during build.
      # executeDuringWatch            # If true the tests will get executed during watch with each file change.
      # specConvention: /[_-](spec|test)\.js$/ # Convention for how test specs are named
      # assetFolder: ".mimosa/testemRequire"        # Path from the root of the project to the folder that will
                                      # contain all the testing assets that the testemRequire
                                      # module maintains and writes. If the folder does not exist
                                      # it will be created.
      # safeAssets: []                # An array of file names testem-require will not overwrite.
                                      # By default testem-require overwrites any file it outputs.
                                      # So, for instance, if you have a specific version of
                                      # "mocha.js" you need to use, this setting should be ["mocha.js"]
      # testemConfig:                 # Pass through values for the testem.json configuration.
                                      # The module will write the testem.json for you
        # "launch_in_dev": ["Firefox", "Chrome"] # In dev mode launches in Firefox and Chrome
        # "launch_in_ci": ["PhantomJS"]          # In CI mode uses PhantomJS (must be installed)
      # mochaSetup:                   # Setup for Mocha
        # ui : 'bdd'                  # Mocha is set to bdd mode by default
      # requireConfig: {}             # RequireJS configuration. By default the mimosa-require
                                      # module is used by mimosa-testem-require to derive a
                                      # requirejs config.  But if that derived config isn't right
                                      # a config can be pasted here.
  """

exports.validate = (config, validators) ->

  errors = []
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
