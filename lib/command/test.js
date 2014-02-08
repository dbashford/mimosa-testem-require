var bash, bat, exec, fs, logger, path, register, _test, _writeBash, _writeBat;

exec = require('child_process').exec;

path = require('path');

fs = require('fs');

logger = null;

bash = "#!/bin/bash\nif [ \"$1\" == ci ]; then\n  testem ci --file \"CONFIG_FILE\"\nelse\n  testem --file \"CONFIG_FILE\"\nfi";

bat = "@echo off\nif \"%1\" == \"ci\" (\n  testem ci --file \"CONFIG_FILE\"\n) else (\n  testem --file \"CONFIG_FILE\"\n)";

_test = function(config, opts) {
  var outPath, relativePath;
  if (config.testemSimple == null) {
    return logger.error("testscript command used, but mimosa-testem-require not configured as project module.");
  }
  relativePath = path.relative(config.root, config.testemSimple.configFile);
  outPath = opts.windows || (!opts.bash && process.platform === "win32") ? _writeBat(relativePath) : _writeBash(relativePath);
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
  return program.command('testscript').description("Create a script in the root directory that will launch testem tests").option("-b, --bash", "force the generation of a bash script").option("-w, --windows", "force the generation of a windows script").action(function(opts) {
    return retrieveConfig(false, false, function(config) {
      logger = config.log;
      return _test(config, opts);
    });
  }).on('--help', (function(_this) {
    return function() {
      logger.green(' This command will create a script to launch testem tests directly.');
      logger.green(' Use this script this command generates when debugging/writing tests.');
      return logger.blue('\n $ mimosa testscript\n');
    };
  })(this));
};

module.exports = register;
