"use strict"

path = require "path"
fs = require "fs"

exports.defaults = ->
  testemSimple = require "mimosa-testem-simple"
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
