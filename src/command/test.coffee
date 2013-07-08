exec = require('child_process').exec
path = require 'path'
fs = require 'fs'

logger = require 'logmimosa'

bash = """
#!/bin/bash
if [ "$1" == ci ]; then
  testem ci --file "CONFIG_FILE"
else
  testem --file "CONFIG_FILE"
fi
"""

bat = """
@echo off
if "%1" == "ci" (
  testem ci --file "CONFIG_FILE"
) else (
  testem --file "CONFIG_FILE"
)
"""

_test = (config, opts) ->
  outPath = if opts.windows or (not opts.bash and process.platform is "win32")
    _writeBat config.testemSimple.configFile
  else
    _writeBash config.testemSimple.configFile

  logger.success "Wrote test execution script to [[ #{outPath} ]]"
  logger.info "To execute the test script, you will need to have testem installed globally. npm install -g testem"

_writeBash = (configFile) ->
  bash = bash.replace /CONFIG_FILE/g, configFile
  outPath = path.join process.cwd(), "test.sh"
  fs.writeFileSync outPath, bash, mode:0o0777
  outPath

_writeBat = (configFile) ->
  bat = bat.replace /CONFIG_FILE/g, configFile
  outPath = path.join process.cwd(), "test.bat"
  fs.writeFileSync outPath, bat, mode:0o0777
  outPath

register = (program, retrieveConfig) ->
  program
    .command('testscript')
    .description("Create a script in the root directory that will launch testem tests")
    .option("-b, --bash",    "force the generation of a bash script")
    .option("-w, --windows", "force the generation of a windows script")
    .action (opts) ->
      retrieveConfig false, (config) ->
        _test config, opts
    .on '--help', =>
      logger.green(' This command will create a script to launch testem tests directly.')
      logger.green(' Use this script this command generates when debugging/writing tests.')
      logger.blue( '\n $ mimosa testscript\n')

module.exports = register