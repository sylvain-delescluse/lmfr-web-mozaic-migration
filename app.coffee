colors = require 'colors'
prompt = require 'prompt'
fs = require 'fs'
q = require 'q'
commandLineArgs = require 'command-line-args'
path = require 'path'

module.exports = class App

  commonMacrosLinkPath: undefined
  commonMacrosButtonPath: undefined

  constructor: ->
    console.log "process.cwd()".cyan, process.cwd()

    @getFilesByExt('ftl', process.cwd(), yes).then (ftlFiles) =>
      console.log 'ftlFiles:', ftlFiles

      for filePath in ftlFiles
        if filePath.indexOf('templates/macros/common') isnt -1
          if filePath.indexOf('templates/macros/common/link.ftl') isnt -1
            @commonMacrosLinkPath = filePath
          if filePath.indexOf('templates/macros/common/button.ftl') isnt -1
            @commonMacrosButtonPath = filePath
        else
          @processHref filePath


  detectMacroImport: (pFileData, pFilePath, pImportFilename) ->
    regex = new RegExp '<#import "([./]*)macros\/common\/' + pImportFilename + '.ftl" as ([a-zA-Z]*)>' , 'gi'
    ftlImports = pFileData.match regex

    if not ftlImports
      pFileData = '<#import "' + path.relative(pFilePath, @commonMacrosLinkPath) + '" as ' + pImportFilename + '>\n' + pFileData

    return pFileData


  processHref: (pPath) ->
    console.log ('\n\nLook for <a > in ' + pPath + '').blue
    fs.readFile pPath, 'utf8', (err, data) =>
      if err
        console.log 'err:'.red, err
      else
        hrefReg = /([ \t]*)<a[^\>]+href=['|"]([^'|"]*)['|"][^\>]*>([\w\W]*?)<\/a>/ig
        ahrefs = data.match hrefReg
        if ahrefs.length > 0
          data = @detectMacroImport data, pPath, 'link'

          ahrefs.forEach (ahref) =>
            console.log '\nahref', ahref

            # Get Class
            regexLinkClass = new RegExp '([ \t]*)<a[^\>]+class=[\'|"]([^\'|"]*)[\'|"][^\>]*>([\\w\\W]*?)<\\/a>', 'gi'
            ahrefClassResult = regexLinkClass.exec ahref
            ahrefIndent = ahrefClassResult[1]
            console.log 'ahrefIndent', ahrefIndent
            ahrefClass = ahrefClassResult[2]
            console.log 'ahrefClass', ahrefClass

            # Get href
            regexLinkHref = new RegExp '([ \t]*)<a[^\>]+href=[\'|"]([^\'|"]*)[\'|"][^\>]*>([\\w\\W]*?)<\\/a>', 'gi'
            ahrefHrefResult = regexLinkHref.exec ahref
            ahrefHref = ahrefHrefResult[2]
            console.log 'ahrefHref', ahrefHref
            ahrefContent = ahrefHrefResult[3]
            console.log 'ahrefContent', ahrefContent
            iconData = @getIconData ahrefContent
            console.log 'iconData', iconData

            regexOnlyHeadTag = /<a[^\>]*>/ig
            ahrefOnlyHeadTag = regexOnlyHeadTag.exec ahref
            ahrefHeadTag = ahrefOnlyHeadTag[0]
            #console.log 'ahrefHeadTag:', ahrefHeadTag

            # Get data attributes
            #regexLinkDataAttr = new RegExp '([ \t]*)<a[^\\>]+data-([\\w]+)=[\'|"]([^\'|"]*)[\'|"][^\\>]*>([\\w\\W]*?)<\\/a>', 'gi'
            #regexLinkDataAttr = /([ \t]*)<a[^\>]+data-((?!cerberus).*?)=['|"]([^'|"]*)['|"][^\>]*>([\w\W]*?)<\/a>/ig
            regexLinkDataAttr = /data-([\w]+)=['|"]([^'|"]*)['|"]/ig
            linkDataAttrs = []
            while ((linkDataAttr = regexLinkDataAttr.exec(ahrefHeadTag)) isnt null)
              linkDataAttrs.push
                name: linkDataAttr[1]
                value: linkDataAttr[2]
            console.log 'linkDataAttrs:'.cyan, linkDataAttrs

            ###
            regexLinkCerberusAttr = /([ \t]*)<a[^\>]+data-cerberus=['|"]([^'|"]*)['|"][^\>]*>([\w\W]*?)<\/a>/ig
            ahrefHrefResult = regexLinkCerberusAttr.exec ahref
            ahrefDataCerberusAttr = if ahrefHrefResult then ahrefHrefResult[2]
            console.log 'ahrefDataCerberusAttr', ahrefDataCerberusAttr
            ###


  getIconData: (pData) ->
    retData = {}
    iconReg = /([^.]*)<@[^\>]+icon[^\>]+iconPath=['|"]([^'|"]*)['|"][^\>]*>([^.]*)/ig
    icons = pData.match iconReg
    if icons and icons.length > 0
      icon = icons[0]
      iconPathRes = iconReg.exec icon
      retData.id = iconPathRes[2]

      iconLeftTextRes = iconPathRes[1].replace /[\s]*/g, ''
      iconRightTextRes = iconPathRes[3].replace /[\s]*/g, ''
      iconLeftTextLength = iconLeftTextRes.length
      iconRightTextLength = iconRightTextRes.length

      if iconLeftTextLength > 0
        retData.side = 'right'

      if iconRightTextLength > 0
        retData.side = 'left'

      retData.iconOnly = (iconLeftTextLength is 0 and iconRightTextLength is 0)

    retData


  getFilesByExt: (pExt, pDir, pWithUnderscore) ->
    deferred = q.defer()
    files = fs.readdirSync pDir

    filesByExt = files.filter (file) ->
      if pWithUnderscore
        return file.indexOf('.' + pExt) isnt -1
      else
        return file.indexOf('.' + pExt) isnt -1 and file.substr(0, 1) isnt '_'

    filesByExt = filesByExt.map (f) ->
      return pDir + '/' + f

    directories = files.filter (file) ->
      if fs.statSync(pDir + '/' + file).isDirectory()
        if pWithUnderscore
          return yes
        else
          return file.substr(0, 1) isnt '_'

    if directories.length > 0
      promises = []
      directories.forEach (dir) =>
        dirPath = pDir + '/' + dir

        if dirPath.indexOf('node_modules') is -1 and dirPath.indexOf('git') is -1
          p = @getFilesByExt pExt, dirPath, pWithUnderscore
          promises.push p

      q.all(promises).then (pResults) ->
        pResults.forEach (fArr) ->
          filesByExt = filesByExt.concat fArr

        deferred.resolve filesByExt

    else
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
