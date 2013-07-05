"use strict";
var path;

path = require("path");

exports.defaults = function() {
  return {
    testemSimple: {
      configFile: ".mimosa/testem.json"
    },
    testemRequire: {
      safeAssets: [],
      specConvention: /_spec\.js$/,
      assetFolder: ".mimosa/testemRequire",
      testemConfig: {
        "launch_in_dev": ["Firefox", "Chrome"],
        "launch_in_ci": ["PhantomJS"]
      },
      mochaSetup: {
        ui: 'bdd'
      },
      requireConfig: null
    }
  };
};

exports.placeholder = function() {
  return "\t\n\n  # testemRequire:                  # Configuration for the testem-require module\n    # specConvention: /_spec\\.js$/ # Convention for how test specs are named\n    # assetFolder: \".mimosa/testemRequire\"        # Path from the root of the project to the folder that will\n                                    # contain all the testing assets that the testemRequire\n                                    # module maintains and writes. If the folder does not exist\n                                    # it will be created.\n    # safeAssets: []                # An array of file names testem-require will not overwrite.\n                                    # By default testem-require overwrites any file it outputs.\n                                    # So, for instance, if you have a specific version of\n                                    # \"mocha.js\" you need to use, this setting should be [\"mocha.js\"]\n    # testemConfig:                 # Pass through values for the testem.json configuration.\n                                    # The module will write the testem.json for you\n      # \"launch_in_dev\": [\"Firefox\", \"Chrome\"] # In dev mode launches in Firefox and Chrome\n      # \"launch_in_ci\": [\"PhantomJS\"]          # In CI mode uses PhantomJS (must be installed)\n    # mochaSetup:                   # Setup for Mocha\n      # ui : 'bdd'                  # Mocha is set to bdd mode by default\n    # requireConfig: {}             # RequireJS configuration. By default the mimosa-require\n                                    # module is used by mimosa-testem-require to derive a\n                                    # requirejs config.  But if that derived config isn't right\n                                    # a config can be pasted here.";
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
    validators.ifExistsIsObject(errors, "testemRequire.requireConfig", config.testemRequire.requireConfig);
    validators.ifExistsIsArrayOfStrings(errors, "testemRequire.safeAssets", config.testemRequire.safeAssets);
    config.testemSimple.configFile = path.join(config.testemRequire.assetFolderFull, "testem.json");
  }
  return errors;
};
