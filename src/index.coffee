"use strict"

path = require "path"
fs = require "fs"

wrench = require "wrench"
_ = require "lodash"
logger = require "logmimosa"
testemSimple = require "mimosa-testem-simple"

config = require './config'

specFiles = []
requireConfig = {}
clientFolder = null
mimosaRequire = null
lastOutputString = null
testVariablesPath = null

allAssets = [
  "mocha.css",
  "runner.html",
  "run-tests.js",
  "require.min.js",
  "chai.js",
  "mocha.js",
  "sinon-chai.js",
  "sinon.js"].map (asset) ->
  path.join __dirname, "..", "assets", asset

registration = (mimosaConfig, register) ->
  e = mimosaConfig.extensions

  unless mimosaConfig.testemRequire.requireConfig
    mimosaRequire = mimosaConfig.installedModules['mimosa-require']
    if not mimosaRequire
      return logger.error "mimosa-testem-require is configured but cannot be used unless mimosa-require is installed and used."

  register ['postBuild'], 'init', _ensureDirectory
  register ['postBuild'], 'init', _writeStaticAssets
  register ['postBuild'], 'init', _writeTestemConfig
  register ['postBuild'], 'init', _buildRequireConfig

  register ['add','update'], 'afterWrite', _buildRequireConfig, e.javascript
  register ['remove'], 'afterWrite', _buildRequireConfig, e.javascript

  register ['add','update','buildFile'], 'afterCompile', _buildSpecs, e.javascript
  register ['remove'], 'afterDelete', _removeSpec, e.javascript

  clientFolder = path.join mimosaConfig.watch.compiledJavascriptDir, "testem-require"
  testVariablesPath = path.join mimosaConfig.testemRequire.assetFolderFull, "test-variables.js"

  testemSimple.registration mimosaConfig, register

_buildRequireConfig = (mimosaConfig, options, next) ->

  requireConfig = if mimosaConfig.testemRequire.requireConfig
    mimosaConfig.testemRequire.requireConfig
  else
    mimosaRequire.requireConfig()

  unless requireConfig.baseUrl
    requireConfig.baseUrl = "/js"

  requireConfigString = JSON.stringify requireConfig, null, 2
  mochaSetupString =  JSON.stringify mimosaConfig.testemRequire.mochaSetup, null, 2
  specFilesString = JSON.stringify specFiles, null, 2

  outputString = """
      window.MIMOSA_TEST_REQUIRE_CONFIG = #{requireConfigString};
      window.MIMOSA_TEST_MOCHA_SETUP = #{mochaSetupString};
      window.MIMOSA_TEST_SPECS = #{specFilesString};
    """

  if not lastOutputString or lastOutputString isnt outputString
    lastOutputString = outputString
    fs.writeFileSync testVariablesPath, outputString

  next()

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

_ensureDirectory = (mimosaConfig, options, next) ->
  folder = mimosaConfig.testemRequire.assetFolderFull
  unless fs.existsSync folder
    wrench.mkdirSyncRecursive folder, 0o0777
  next()

_writeStaticAssets = (mimosaConfig, options, next) ->
  tr = mimosaConfig.testemRequire

  allAssets.filter (asset) ->
    tr.safeAssets.indexOf(path.basename(asset)) is -1
  .forEach (asset) ->
    fileName = path.basename asset
    outFile = path.join tr.assetFolderFull, fileName
    if fs.existsSync outFile
      statInFile = fs.statSync asset
      statOutFile = fs.statSync outFile
      if statInFile.mtime > statOutFile.mtime
        __writeFile asset, outFile
    else
      __writeFile asset, outFile

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
      specPath = specPath.replace path.extname(specPath), ""
      specPath = specPath.split(path.sep).join('/')
      manipulateSpecs specPath

__craftTestemConfig = (mimosaConfig, currentTestemConfig) ->
  currentTestemConfig.test_page = "#{mimosaConfig.testemRequire.assetFolder}/runner.html"
  unless currentTestemConfig.routes
    currentTestemConfig.routes = {}
  jsDir = path.relative mimosaConfig.root, mimosaConfig.watch.compiledJavascriptDir
  currentTestemConfig.routes["/js"] = jsDir.split(path.sep).join('/')
  _.extend currentTestemConfig, mimosaConfig.testemRequire.testemConfig

__writeFile = (inPath, outPath) ->
  logger.debug "Writing mimosa-testem-require file [[ #{outPath} ]]"
  fileText = fs.readFileSync inPath, "utf8"
  fs.writeFileSync outPath, fileText

module.exports =
  registration:    registration
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate