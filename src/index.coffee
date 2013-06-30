"use strict"

path = require "path"
fs = require "fs"

wrench = require "wrench"
_ = require "lodash"
logger = require "logmimosa"

config = require './config'

specFiles = []
requireConfig = {}
clientFolder = ""

runnerAssets = ["mocha.css", "runner.html", "config.js"].map (asset) ->
  path.join __dirname, "..", "assets", "runner", asset

clientAssets = ["chai.js", "mocha.js", "sinon-chai.js", "sinon.js"].map (asset) ->
  path.join __dirname, "..", "assets", "client", asset

registration = (mimosaConfig, register) ->

  clientFolder = path.join mimosaConfig.watch.compiledJavascriptDir, "testem-require"

  e = mimosaConfig.extensions
  register ['postBuild'], 'init', _ensureDirectories
  register ['postBuild'], 'init', _writeStaticAssets
  register ['postBuild'], 'init', _writeTestemConfig

  register ['add','update','buildFile'], 'afterCompile', _buildSpecs, e.javascript
  register ['remove'], 'afterDelete', _removeSpec, e.javascript

_buildSpecs = (mimosaConfig, options, next) ->
  __specs mimosaConfig, options, (specPath) ->
    if specFiles.indexOf(specPath) is -1
      specFiles.push specPath

  next()

_removeSpec = (mimosaConfig, options, next) ->
  __specs mimosaConfig, options, (specPath) ->
    specFileLoc = specFiles.indexOf(specPath)
    if specFileLoc > -1
      specFiles.splice specFileLoc, 1
  next()

_ensureDirectories = (mimosaConfig, options, next) ->
  [mimosaConfig.testemRequire.assetFolderFull, clientFolder].forEach (folder) ->
    unless fs.existsSync folder
      wrench.mkdirSyncRecursive folder, 0o0777

  next()

_writeStaticAssets = (mimosaConfig, options, next) ->
  tr = mimosaConfig.testemRequire
  __writeAssets tr.overwriteAssets, runnerAssets, tr.assetFolderFull
  __writeAssets tr.overwriteAssets, clientAssets, clientFolder
  next()

_writeTestemConfig = (mimosaConfig, options, next) ->
  testemConfigPath = path.join mimosaConfig.root, "testem.json"
  currentTestemConfig = {}
  if fs.existsSync testemConfigPath
    try
      currentTestemConfig = require testemConfigPath
    catch err
      logger.fatal "Problem reading testem config, ", err
      process.exit 1

  testemConfig = __craftTestemConfig mimosaConfig, _.clone(currentTestemConfig)
  testemConfigPretty = JSON.stringify testemConfig, null, 2

  unless JSON.stringify(currentTestemConfig, null, 2) is testemConfigPretty
    logger.debug "Writing testem configuration to [[ #{testemConfigPath} ]]"
    fs.writeFileSync testemConfigPath, testemConfigPretty

  next()

__specs = (mimosaConfig, options, manipulateSpecs) ->
  for file in options.files
    if mimosaConfig.testemRequire.specConvention.test(file.outputFileName)
      specPath = file.outputFileName.replace(mimosaConfig.watch.compiledJavascriptDir + path.sep, "")
      specPath = specPath.split(path.sep).join('/')
      manipulateSpecs specPath

__craftTestemConfig = (mimosaConfig, currentTestemConfig) ->
  currentTestemConfig.test_page = "#{mimosaConfig.testemRequire.assetFolder}/runner.html"
  javascriptRoot = mimosaConfig.watch.compiledJavascriptDir.replace(mimosaConfig.root + path.sep, "")
  unless currentTestemConfig.routes
    currentTestemConfig.routes = {}
  currentTestemConfig.routes["/js"] = javascriptRoot.split(path.sep).join('/')
  _.extend(currentTestemConfig, mimosaConfig.testemRequire.testemConfig)

__writeAssets = (overwriteAssets, assets, folder) ->
  assets.forEach (asset) ->
    fileName = path.basename asset
    outFile = path.join folder, fileName
    if fs.existsSync outFile
      if overwriteAssets
        statInFile = fs.statSync asset
        statOutFile = fs.statSync outFile
        if statInFile.mtime > statOutFile.mtime
          __writeFile asset, outFile
    else
      __writeFile asset, outFile

__writeFile = (inPath, outPath) ->
  logger.debug "Writing mimosa-testem-require file [[ #{outPath} ]]"
  fileText = fs.readFileSync inPath, "utf8"
  fs.writeFileSync outPath, fileText

module.exports =
  registration:    registration
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate