"use strict";
var path;

path = require("path");

exports.defaults = function() {
  return {
    testemRequire: {
      specConvention: /_spec\.js$/,
      assetFolder: ".testemRequire",
      testemConfig: {
        "launch_in_dev": ["Firefox", "Chrome"],
        "launch_in_ci": ["PhantomJS"]
      },
      mochaSetup: {
        ui: 'bdd'
      }
    }
  };
};

exports.placeholder = function() {
  return "\t\n\n  # testemRequire:                  # Configuration for the testem-require module\n    # specConvention: /_spec\\.js$/ # Convention for how test specs are named\n    # assetFolder: \".testemRequire\" # Path from the root of the project to the folder that will\n                                    # contain all the testing assets that the testemRequire\n                                    # module maintains and writes. If the folder does not exist\n                                    # it will be created.\n    # overwriteAssets: true         # Determines if module will overwrite testing assets if newer\n                                    # assets are available.  Set this to false if you've tinkered\n                                    # with the assets that mimosa-testem-require devlivers,\n                                    # otherwise those changes will disappear.\n    # testemConfig:                   # Pass through values for the testem.json configuration.\n                                      # The module will write the testem.json for you\n      # \"launch_in_dev\": [\"Firefox\", \"Chrome\"] # In dev mode launches in Firefox and Chrome\n      # \"launch_in_ci\": [\"PhantomJS\"]          # In CI mode uses PhantomJS (must be installed)\n    # mochaSetup:                     # Setup for Mocha\n      # ui : 'bdd'                    # Mocha is set to bdd mode by default";
};

exports.validate = function(config, validators) {
  var errors;
  errors = [];
  if (validators.ifExistsIsObject(errors, "testemRequire config", config.testemRequire)) {
    if (validators.ifExistsIsString(errors, "testemRequire.assetFolder", config.testemRequire.assetFolder)) {
      config.testemRequire.assetFolderFull = path.join(config.root, config.testemRequire.assetFolder);
    }
    validators.ifExistsIsObject(errors, "testemRequire.testemConfig", config.testemRequire.testemConfig);
    validators.ifExistsIsObject(errors, "testemRequire.mochaSetup", config.testemRequire.mochaSetup);
  }
  return errors;
};
