var bash, bat, exec, fs, logger, path, register, _test, _writeBash, _writeBat;

exec = require('child_process').exec;

path = require('path');

fs = require('fs');

logger = require('logmimosa');

bash = "#!/bin/bash\nif [ \"$1\" == ci ]; then\n  testem ci --file \"CONFIG_FILE\"\nelse\n  testem --file \"CONFIG_FILE\"\nfi";

bat = "@echo off\nif \"%1\" == \"ci\" (\n  testem ci --file \"CONFIG_FILE\"\n) else (\n  testem --file \"CONFIG_FILE\"\n)";

_test = function(config, opts) {
  var outPath;
  outPath = opts.windows || (!opts.bash && process.platform === "win32") ? _writeBat(config.testemSimple.configFile) : _writeBash(config.testemSimple.configFile);
  logger.success("Wrote test execution script to [[ " + outPath + " ]]");
  return logger.info("To execute the test script, you will need to have testem installed globally. npm install -g testem");
};

_writeBash = function(configFile) {
  var outPath;
  bash = bash.replace(/CONFIG_FILE/g, configFile);
  outPath = path.join(process.cwd(), "test.sh");
  fs.writeFileSync(outPath, bash, {
    mode: 0x1ff
  });
  return outPath;
};

_writeBat = function(configFile) {
  var outPath;
  bat = bat.replace(/CONFIG_FILE/g, configFile);
  outPath = path.join(process.cwd(), "test.bat");
  fs.writeFileSync(outPath, bat, {
    mode: 0x1ff
  });
  return outPath;
};

register = function(program, retrieveConfig) {
  var _this = this;
  return program.command('testscript').description("Create a script in the root directory that will launch testem tests").option("-b, --bash", "force the generation of a bash script").option("-w, --windows", "force the generation of a windows script").action(function(opts) {
    return retrieveConfig(false, function(config) {
      return _test(config, opts);
    });
  }).on('--help', function() {
    logger.green(' This command will create a script to launch testem tests directly.');
    logger.green(' Use this script this command generates when debugging/writing tests.');
    return logger.blue('\n $ mimosa testscript\n');
  });
};

module.exports = register;
