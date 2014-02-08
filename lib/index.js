"use strict";
var allAssets, clientFolder, config, fs, lastOutputString, logger, mimosaRequire, path, registration, requireConfig, specFiles, test, testVariablesPath, testemSimple, wrench, _, __craftTestemConfig, __specs, __writeFile, _buildRequireConfig, _buildSpecs, _ensureDirectory, _removeSpec, _writeStaticAssets, _writeTestemConfig;

path = require("path");

fs = require("fs");

wrench = require("wrench");

_ = require("lodash");

testemSimple = require("mimosa-testem-simple");

config = require('./config');

test = require('./command/test');

specFiles = [];

requireConfig = {};

clientFolder = null;

mimosaRequire = null;

lastOutputString = null;

testVariablesPath = null;

logger = null;

allAssets = ["mocha.css", "runner.html", "run-tests.js", "require.min.js", "chai.js", "mocha.js", "sinon-chai.js", "sinon.js"].map(function(asset) {
  return path.join(__dirname, "..", "assets", asset);
});

registration = function(mimosaConfig, register) {
  var e;
  logger = mimosaConfig.log;
  e = mimosaConfig.extensions;
  if (!mimosaConfig.testemRequire.requireConfig) {
    mimosaRequire = mimosaConfig.installedModules['mimosa-require'];
    if (!mimosaRequire) {
      return logger.error("mimosa-testem-require is configured but cannot be used unless mimosa-require is installed and used.");
    }
  }
  register(['postBuild'], 'init', _ensureDirectory);
  register(['postBuild'], 'init', _writeStaticAssets);
  register(['postBuild'], 'init', _writeTestemConfig);
  register(['postBuild'], 'init', _buildRequireConfig);
  register(['add', 'update'], 'afterWrite', _buildRequireConfig, e.javascript);
  register(['remove'], 'afterWrite', _buildRequireConfig, e.javascript);
  register(['add', 'update'], 'afterCompile', _buildSpecs, e.javascript);
  register(['buildFile'], 'init', _buildSpecs, e.javascript);
  register(['remove'], 'afterDelete', _removeSpec, e.javascript);
  clientFolder = path.join(mimosaConfig.watch.compiledJavascriptDir, "testem-require");
  testVariablesPath = path.join(mimosaConfig.testemRequire.assetFolderFull, "test-variables.js");
  if ((mimosaConfig.testemRequire.executeDuringBuild && mimosaConfig.isBuild) || (mimosaConfig.testemRequire.executeDuringWatch && mimosaConfig.isWatch)) {
    return testemSimple.registration(mimosaConfig, register);
  }
};

_buildRequireConfig = function(mimosaConfig, options, next) {
  var mochaSetupString, newRequireConfig, outputString, requireConfigString, specFilesString;
  requireConfig = mimosaConfig.testemRequire.requireConfig ? mimosaConfig.testemRequire.requireConfig : mimosaRequire.requireConfig();
  if (!requireConfig.baseUrl) {
    requireConfig.baseUrl = "/js";
  }
  newRequireConfig = {};
  _.sortBy(Object.keys(requireConfig), function(k) {
    return -k.length;
  }).forEach(function(k) {
    return newRequireConfig[k] = requireConfig[k];
  });
  requireConfigString = JSON.stringify(newRequireConfig, null, 2);
  mochaSetupString = JSON.stringify(mimosaConfig.testemRequire.mochaSetup, null, 2);
  specFilesString = JSON.stringify(specFiles.sort(), null, 2);
  outputString = "window.MIMOSA_TEST_REQUIRE_CONFIG = " + requireConfigString + ";\nwindow.MIMOSA_TEST_MOCHA_SETUP = " + mochaSetupString + ";\nwindow.MIMOSA_TEST_SPECS = " + specFilesString + ";";
  if (!lastOutputString || lastOutputString !== outputString) {
    lastOutputString = outputString;
    fs.writeFileSync(testVariablesPath, outputString);
  }
  return next();
};

_buildSpecs = function(mimosaConfig, options, next) {
  __specs(mimosaConfig, options, function(specPath) {
    if (specFiles.indexOf(specPath) === -1) {
      return specFiles.push(specPath);
    }
  });
  return next();
};

_removeSpec = function(mimosaConfig, options, next) {
  __specs(mimosaConfig, options, function(specPath) {
    var specFileLoc;
    specFileLoc = specFiles.indexOf(specPath);
    if (specFileLoc > -1) {
      return specFiles.splice(specFileLoc, 1);
    }
  });
  return next();
};

_ensureDirectory = function(mimosaConfig, options, next) {
  var folder;
  folder = mimosaConfig.testemRequire.assetFolderFull;
  if (!fs.existsSync(folder)) {
    wrench.mkdirSyncRecursive(folder, 0x1ff);
  }
  return next();
};

_writeStaticAssets = function(mimosaConfig, options, next) {
  var tr;
  tr = mimosaConfig.testemRequire;
  allAssets.filter(function(asset) {
    return tr.safeAssets.indexOf(path.basename(asset)) === -1;
  }).forEach(function(asset) {
    var fileName, outFile, statInFile, statOutFile;
    fileName = path.basename(asset);
    outFile = path.join(tr.assetFolderFull, fileName);
    if (fs.existsSync(outFile)) {
      statInFile = fs.statSync(asset);
      statOutFile = fs.statSync(outFile);
      if (statInFile.mtime > statOutFile.mtime) {
        return __writeFile(asset, outFile);
      }
    } else {
      return __writeFile(asset, outFile);
    }
  });
  return next();
};

_writeTestemConfig = function(mimosaConfig, options, next) {
  var currentTestemConfig, err, testemConfig, testemConfigPretty;
  currentTestemConfig = {};
  if (fs.existsSync(mimosaConfig.testemSimple.configFile)) {
    try {
      currentTestemConfig = require(mimosaConfig.testemSimple.configFile);
    } catch (_error) {
      err = _error;
      logger.fatal("Problem reading testem config, ", err);
      process.exit(1);
    }
  }
  testemConfig = __craftTestemConfig(mimosaConfig, _.clone(currentTestemConfig));
  testemConfigPretty = JSON.stringify(testemConfig, null, 2);
  if (JSON.stringify(currentTestemConfig, null, 2) !== testemConfigPretty) {
    logger.debug("Writing testem configuration to [[ " + mimosaConfig.testemSimple.configFile + " ]]");
    fs.writeFileSync(mimosaConfig.testemSimple.configFile, testemConfigPretty);
  }
  return next();
};

__specs = function(mimosaConfig, options, manipulateSpecs) {
  var file, specPath, _i, _len, _ref, _results;
  _ref = options.files;
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    file = _ref[_i];
    if (mimosaConfig.testemRequire.specConvention.test(file.outputFileName)) {
      specPath = file.outputFileName.replace(mimosaConfig.watch.compiledJavascriptDir + path.sep, "");
      specPath = specPath.replace(path.extname(specPath), "");
      specPath = specPath.split(path.sep).join('/');
      _results.push(manipulateSpecs(specPath));
    } else {
      _results.push(void 0);
    }
  }
  return _results;
};

__craftTestemConfig = function(mimosaConfig, currentTestemConfig) {
  var jsDir;
  currentTestemConfig.test_page = "" + mimosaConfig.testemRequire.assetFolder + "/runner.html";
  if (!currentTestemConfig.routes) {
    currentTestemConfig.routes = {};
  }
  jsDir = path.relative(mimosaConfig.root, mimosaConfig.watch.compiledJavascriptDir);
  currentTestemConfig.routes["/js"] = jsDir.split(path.sep).join('/');
  return _.extend(currentTestemConfig, mimosaConfig.testemRequire.testemConfig);
};

__writeFile = function(inPath, outPath) {
  var fileText;
  logger.debug("Writing mimosa-testem-require file [[ " + outPath + " ]]");
  fileText = fs.readFileSync(inPath, "utf8");
  return fs.writeFileSync(outPath, fileText);
};

module.exports = {
  registration: registration,
  defaults: config.defaults,
  placeholder: config.placeholder,
  validate: config.validate,
  registerCommand: test
};
