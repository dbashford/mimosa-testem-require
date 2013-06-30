"use strict"

path = require "path"

exports.defaults = ->
  testemRequire:
    specConvention: /_spec\.js$/
    assetFolder:".testemRequire"
    testemConfig:
      "launch_in_dev": ["Firefox", "Chrome"]
      "launch_in_ci": ["PhantomJS"]
    mochaSetup:
      ui: 'bdd'


exports.placeholder = ->
  """
  \t

    # testemRequire:                  # Configuration for the testem-require module
      # specConvention: /_spec\\.js$/ # Convention for how test specs are named
      # assetFolder: ".testemRequire" # Path from the root of the project to the folder that will
                                      # contain all the testing assets that the testemRequire
                                      # module maintains and writes. If the folder does not exist
                                      # it will be created.
      # overwriteAssets: true         # Determines if module will overwrite testing assets if newer
                                      # assets are available.  Set this to false if you've tinkered
                                      # with the assets that mimosa-testem-require devlivers,
                                      # otherwise those changes will disappear.
      # testemConfig:                   # Pass through values for the testem.json configuration.
                                        # The module will write the testem.json for you
        # "launch_in_dev": ["Firefox", "Chrome"] # In dev mode launches in Firefox and Chrome
        # "launch_in_ci": ["PhantomJS"]          # In CI mode uses PhantomJS (must be installed)
      # mochaSetup:                     # Setup for Mocha
        # ui : 'bdd'                    # Mocha is set to bdd mode by default
  """

exports.validate = (config, validators) ->

  errors = []
  if validators.ifExistsIsObject(errors, "testemRequire config", config.testemRequire)
    if validators.ifExistsIsString(errors, "testemRequire.assetFolder", config.testemRequire.assetFolder)
      config.testemRequire.assetFolderFull = path.join config.root, config.testemRequire.assetFolder
    validators.ifExistsIsObject(errors, "testemRequire.testemConfig", config.testemRequire.testemConfig)
    validators.ifExistsIsObject(errors, "testemRequire.mochaSetup", config.testemRequire.mochaSetup)

  errors
