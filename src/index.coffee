"use strict"

config = require './config'

specFiles = []
requireConfig = {}

registration = (mimosaConfig, register) ->
  ###
  e = mimosaConfig.extensions
  register ['add','update','buildFile'],      'afterCompile', _minifyJS, e.javascript
  register ['add','update','buildExtension'], 'beforeWrite',  _minifyJS, e.template
  ###

_minifyJS = (mimosaConfig, options, next) ->


registerCommand = (program, retrieveConfig) ->
  ###
  program
    .command('test')
    .description("Do something fooey")
    .action ->
      retrieveConfig false, config ->
  ###

module.exports =
  registration:    registration
  registerCommand: registerCommand
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate