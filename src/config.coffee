"use strict"

exports.defaults = ->
  ###
  minify:
    exclude:["\\.min\\."]
  ###
  {}

exports.placeholder = ->
  ###
  """
  \t

    # minify:                  # Configuration for non-require minification/compression via uglify
                               # using the --minify flag.
      # exclude:[/\\.min\\./]    # List of regexes to exclude files when running minification.
                               # Any path with ".min." in its name, like jquery.min.js, is assumed to
                               # already be minified and is ignored by default. Override this property
                               # if you have other files that you'd like to exempt from minification.
  """
  ###
  ""

exports.validate = (config, validators) ->

  errors = []
  ###
  if validators.ifExistsIsObject(errors, "minify config", config.minify)
    if validators.ifExistsIsArray(errors, "minify.exclude", config.minify.exclude)
      for ex in config.minify.exclude
        unless typeof ex is "string"
          errors.push "minify.exclude must be an array of strings"
          break

  if errors.length is 0 and config.minify.exclude?.length > 0
    config.minify.exclude = new RegExp config.minify.exclude.join("|"), "i"
  ###
  errors
