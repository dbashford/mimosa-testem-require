mimosa-testem-require
===========

## Overview

This is a [Mimosa](http://mimosa.io) module that integrates testem + mocha into your RequireJS-enabled Mimosa application.

Client JavaScript testing requires a good deal of configuration to set up, as well as plenty of research and trial and error before you can start writing tests. The goal of this module is to keep the amount of configuration you need to create to a minimum.  Out of the box it requires no configuration. The module writes its own configuration derived from your project. Include the module and start writing tests!

This module incorporates [Sinon](http://sinonjs.org/), [Chai](http://chaijs.com/), [Mocha](http://visionmedia.github.io/mocha/), [Testem](https://github.com/airportyh/testem) and [PhantomJS](http://phantomjs.org/).

For more information regarding Mimosa, see http://mimosa.io

Note: To use mimosa-testem-require with mimosa `v1.0.0-rc.3`, you need mimosa-testem-require `v0.6.5`

## Docs, bah, show me some code!

Check out the [MimosaTestem demo app](https://github.com/dbashford/MimosaTestem) to see this module in action.

## Usage

* `npm install -g phantomjs` (If you are on Windows, this will not install phantomjs properly. You will need to [download phantomjs from the site](http://phantomjs.org/download.html) and add the executable to your `PATH`)
* Add `'testem-require'` to your list of modules.  Mimosa will install the module for you when you start up.
* Write tests!  By default `testem-require` considers any file compiled/copied to `watch.compiledDir` that ends with `-spec.js`, `_spec.js`, `-test.js` or `_test.js` a test. Code your specs in `watch.sourceDir` and you can code it in CoffeeScript, LiveScript, whatever. Mimosa will treat it like any other piece of CoffeeScript.

## Functionality

`testem-require` will create a series of assets it needs for testing in `.mimosa/testemRequire` at the root of your project.  That includes `runner.html`, `mocha.js`, `mocha.css`, `chai.js`, `sinon.js`, `sinon-chai.js`, and a copy of `require.js`.  It also includes a file for kicking off tests, and a file declaring your test files and requirejs config that is dynamically generated based on your code.

`testem-require` also generates a `testem.json` config file for configuring the test running.  By default that testem is configured to run all your mocha tests in a PhantomJS headless browser.

When mimosa starts up, `testem-require` will write all the assets and execute your tests.  It will then execute those tests every time a JavaScript file changes.  If all the tests pass, a message will say as much on the console and you will not be notified any other way.  If tests fail,  the console will have the details of the test failure and a Growl message will get sent letting you know a test has broken.

## Command

### mimosa testscript

The `testscript` command will drop a platform appropriate script in the root of your project that you can use to execute your testem tests directory.  If you are writing tests or doing heavy test debugging, you will want to interact with testem without Mimosa getting in the way, or with Mimosa running in another process.  `testem-require` creates all the files, inlines your test output and lets you know when things are broken, but its not really the place to do heavy test coding/debugging.

The script will be named test.[bat/sh]. The script takes a single option of ci.  When ci is passed in, testem will run in ci mode.

```
mimosa testscript
```

```
test.sh
test.sh ci
```

## Default Config

```
  testemRequire:
    safeAssets: []
    specConvention: /[_-](spec|test)\.js$/
    assetFolder:".mimosa/testemRequire"
    testemConfig:
      "launch_in_dev": ["Firefox", "Chrome"]
      "launch_in_ci": ["PhantomJS"]
    mochaSetup:
      ui: 'bdd'
    requireConfig: null
```

* `safeAssets`: You may choose to alter the assets that Mimosa writes, for instance to use your own version of mocha.  Mimosa by default will overwrite the files in this folder.  If you don't want your file overwritten, add the name of the file to this array.  Just the name, no paths necessary.
* `specConvention`: This is the regex `testem-require` uses to identify your tests. It'll run this regex against every compiled file to determine if it is indeed a test and if it is, `testem-require` will include it in the list of tests to be run.
*  `assetFolder`: This is the folder `testem-require` places its assets.
*  `testemConfig`: This is testem's configuration.  `testem-require` uses this default, which just defines the browsers to run the tests in, and then amplifies it with a few other computed properties
*  `mochaSetup`: This is a pass-through to the `mocha.setup` command.
*  `requireConfig` This is the configuration used by require.js in your tests.  By default `testem-require` derives this from your project.  To see what it derives, look at `.mimosa/testemRequire/test-variables.js`.