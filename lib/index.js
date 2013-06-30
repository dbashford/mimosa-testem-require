"use strict";
var clientAssets, clientFolder, config, fs, logger, path, registration, requireConfig, runnerAssets, specFiles, wrench, _, __craftTestemConfig, __specs, __writeAssets, __writeFile, _buildSpecs, _ensureDirectories, _removeSpec, _writeStaticAssets, _writeTestemConfig;

path = require("path");

fs = require("fs");

wrench = require("wrench");

_ = require("lodash");

logger = require("logmimosa");

config = require('./config');

specFiles = [];

requireConfig = {};

clientFolder = "";

runnerAssets = ["mocha.css", "runner.html", "config.js"].map(function(asset) {
  return path.join(__dirname, "..", "assets", "runner", asset);
});

clientAssets = ["chai.js", "mocha.js", "sinon-chai.js", "sinon.js"].map(function(asset) {
  return path.join(__dirname, "..", "assets", "client", asset);
});

registration = function(mimosaConfig, register) {
  var e;
  clientFolder = path.join(mimosaConfig.watch.compiledJavascriptDir, "testem-require");
  e = mimosaConfig.extensions;
  register(['postBuild'], 'init', _ensureDirectories);
  register(['postBuild'], 'init', _writeStaticAssets);
  register(['postBuild'], 'init', _writeTestemConfig);
  register(['add', 'update', 'buildFile'], 'afterCompile', _buildSpecs, e.javascript);
  return register(['remove'], 'afterDelete', _removeSpec, e.javascript);
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

_ensureDirectories = function(mimosaConfig, options, next) {
  [mimosaConfig.testemRequire.assetFolderFull, clientFolder].forEach(function(folder) {
    if (!fs.existsSync(folder)) {
      return wrench.mkdirSyncRecursive(folder, 0x1ff);
    }
  });
  return next();
};

_writeStaticAssets = function(mimosaConfig, options, next) {
  var tr;
  tr = mimosaConfig.testemRequire;
  __writeAssets(tr.overwriteAssets, runnerAssets, tr.assetFolderFull);
  __writeAssets(tr.overwriteAssets, clientAssets, clientFolder);
  return next();
};

_writeTestemConfig = function(mimosaConfig, options, next) {
  var currentTestemConfig, err, testemConfig, testemConfigPath, testemConfigPretty;
  testemConfigPath = path.join(mimosaConfig.root, "testem.json");
  currentTestemConfig = {};
  if (fs.existsSync(testemConfigPath)) {
    try {
      currentTestemConfig = require(testemConfigPath);
    } catch (_error) {
      err = _error;
      logger.fatal("Problem reading testem config, ", err);
      process.exit(1);
    }
  }
  testemConfig = __craftTestemConfig(mimosaConfig, _.clone(currentTestemConfig));
  testemConfigPretty = JSON.stringify(testemConfig, null, 2);
  if (JSON.stringify(currentTestemConfig, null, 2) !== testemConfigPretty) {
    logger.debug("Writing testem configuration to [[ " + testemConfigPath + " ]]");
    fs.writeFileSync(testemConfigPath, testemConfigPretty);
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
      specPath = specPath.split(path.sep).join('/');
      _results.push(manipulateSpecs(specPath));
    } else {
      _results.push(void 0);
    }
  }
  return _results;
};

__craftTestemConfig = function(mimosaConfig, currentTestemConfig) {
  var javascriptRoot;
  currentTestemConfig.test_page = "" + mimosaConfig.testemRequire.assetFolder + "/runner.html";
  javascriptRoot = mimosaConfig.watch.compiledJavascriptDir.replace(mimosaConfig.root + path.sep, "");
  if (!currentTestemConfig.routes) {
    currentTestemConfig.routes = {};
  }
  currentTestemConfig.routes["/js"] = javascriptRoot.split(path.sep).join('/');
  return _.extend(currentTestemConfig, mimosaConfig.testemRequire.testemConfig);
};

__writeAssets = function(overwriteAssets, assets, folder) {
  return assets.forEach(function(asset) {
    var fileName, outFile, statInFile, statOutFile;
    fileName = path.basename(asset);
    outFile = path.join(folder, fileName);
    if (fs.existsSync(outFile)) {
      if (overwriteAssets) {
        statInFile = fs.statSync(asset);
        statOutFile = fs.statSync(outFile);
        if (statInFile.mtime > statOutFile.mtime) {
          return __writeFile(asset, outFile);
        }
      }
    } else {
      return __writeFile(asset, outFile);
    }
  });
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
  validate: config.validate
};
