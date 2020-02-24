colors = require 'colors'
prompt = require 'prompt'
fs = require 'fs'
q = require 'q'
commandLineArgs = require 'command-line-args'
path = require 'path'

module.exports = class App

  constructor: ->
    console.log "process.cwd()".cyan, process.cwd()

    @getFilesByExt('ftl', no).then (ftlFiles) ->
      console.log 'ftlFiles:', ftlFiles


  getFilesByExt: (pExt, pWithUnderscore) ->
    deferred = q.defer()
    fs.readdir process.cwd(), (err, files) ->
      if err
        console.log 'err:'.red, err
        deferred.reject err
      else
        filesByExt = files.filter (file) ->
          if pWithUnderscore
            return file.indexOf('.' + pExt) isnt -1
          else
            return file.indexOf('.' + pExt) isnt -1 and file.substr(0, 1) isnt '_'

        if filesByExt.length is 0
          console.log ('No .' + pExt + ' files found!').red
          deferred.resolve []
        else
          console.log filesByExt.length + ' file(s) (with extension ".' + pExt + '") found!'
          deferred.resolve filesByExt

    deferred.promise


  writeDataInFile: (pType, pPath, pData) ->
    console.log ('Overwrite ' + pType + ' file !!!').yellow
    deferred = q.defer()

    relative = path.relative process.cwd(), pPath
    console.log (' relative path:').blue, relative

    try
      fs.writeFile pPath, pData, 'utf8', (err, data) ->
        if err
          console.log (' Error to write ' + pType + ' the file').red, err
          deferred.reject err
        else
          console.log (' The ' + pType + ' file has been overwritten').green
          deferred.resolve()
    catch error
      console.log 'catch error'.red, error
      deferred.reject error

    deferred.promise


app = new App()
