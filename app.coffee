colors = require 'colors'
prompt = require 'prompt'
fs = require 'fs'
q = require 'q'
commandLineArgs = require 'command-line-args'
path = require 'path'

module.exports = class App

  commonMacrosLinkPath: undefined
  commonMacrosButtonPath: undefined

  macroLinkConfigCount: 0

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
    console.log ('\nLook for <a > in ' + pPath + '').blue
    fs.readFile pPath, 'utf8', (err, data) =>
      if err
        console.log 'err:'.red, err
      else
        hrefReg = /([ \t]*)<a[^\>]+href=['|"]([^'|"]*)['|"][^\>]*>([\w\W]*?)<\/a>/ig
        ahrefs = data.match hrefReg
        if ahrefs and ahrefs.length > 0
          data = @detectMacroImport data, pPath, 'link'

          ahrefs.forEach (ahref) =>
            console.log '\nahref', ahref

            # Get Class
            regexLinkClass = new RegExp '([ \t]*)<a[^\>]+class=[\'|"]([^\'|"]*)[\'|"][^\>]*>([\\w\\W]*?)<\\/a>', 'gi'
            ahrefClassResult = regexLinkClass.exec ahref
            ahrefIndent = ahrefClassResult[1]
            #console.log 'ahrefIndent', ahrefIndent
            ahrefClass = ahrefClassResult[2]
            #console.log 'ahrefClass', ahrefClass

            # Get href
            regexLinkHref = new RegExp '([ \t]*)<a[^\>]+href=[\'|"]([^\'|"]*)[\'|"][^\>]*>([\\w\\W]*?)<\\/a>', 'gi'
            ahrefHrefResult = regexLinkHref.exec ahref
            ahrefHref = ahrefHrefResult[2]
            #console.log 'ahrefHref', ahrefHref
            ahrefContent = ahrefHrefResult[3]
            #console.log 'ahrefContent', ahrefContent
            iconData = @getIconData ahrefContent
            #console.log 'iconData', iconData

            regexOnlyHeadTag = /<a[^\>]*>/ig
            ahrefOnlyHeadTag = regexOnlyHeadTag.exec ahref
            ahrefHeadTag = ahrefOnlyHeadTag[0]

            # Get data attributes
            regexLinkDataAttr = /data-([\w]+)=['|"]([^'|"]*)['|"]/ig
            linkDataAttrs = []
            while ((linkDataAttr = regexLinkDataAttr.exec(ahrefHeadTag)) isnt null)
              if linkDataAttr[1] is 'cerberus'
                ahrefDataCerberusAttr = linkDataAttr[2]
              else
                linkDataAttrs.push
                  name: linkDataAttr[1]
                  value: linkDataAttr[2]
            #console.log 'linkDataAttrs:'.cyan, linkDataAttrs
            #console.log 'ahrefDataCerberusAttr:'.cyan, ahrefDataCerberusAttr

            macroLinkData =
              href: ahrefHref
              icon: iconData
              #dataTagco: 'todo'
              #dataTcevent: 'todo'
              cerberus: ahrefDataCerberusAttr
              dataAttributes: linkDataAttrs

              content: ahrefContent
              indent: ahrefIndent

            if ahrefClass.indexOf('ka-link--s') isnt -1
              macroLinkData.size = 's'

            ahrefClass = ahrefClass.replace 'ka-link--s', ''
            ahrefClass = ahrefClass.replace 'ka-link', ''

            macroLinkData.cssClass = ahrefClass.trim()

            data = @replaceLinkWithMacro pPath, data, ahref, macroLinkData

          @writeDataInFile pPath, data


  keepLastWord: (pPath) ->
    pathArr = pPath.split '/'
    lastPathNameExt = pathArr[pathArr.length - 1]
    lastPathNameArr = lastPathNameExt.split '.'
    lastPathName = String(lastPathNameArr[0]).toLowerCase()
    lastPathName


  replaceLinkWithMacro: (pPath, pFileData, pLinkSrc, pLinkData) ->
    lastPathName = @keepLastWord pPath

    if pLinkData.href and pLinkData.href isnt '' and pLinkData.href isnt '#'
      lastPathName += @keepLastWord pLinkData.href

    lastPathName = lastPathName.replace /[^a-z0-9]*/gi, ''
    configName = lastPathName + @macroLinkConfigCount + 'LinkConfig'
    @macroLinkConfigCount++

    linkConfigStr = pLinkData.indent + '<#assign ' + configName + ' = {\n'
    if pLinkData.href then linkConfigStr += '' + pLinkData.indent + '    "href": "' + pLinkData.href + '",\n'
    if pLinkData.size then linkConfigStr += '' + pLinkData.indent + '    "size": "' + pLinkData.size + '",\n'
    if pLinkData.icon and Object.keys(pLinkData.icon).length > 0 then linkConfigStr += '' + pLinkData.indent + '    "icon": ' + JSON.stringify(pLinkData.icon) + ',\n'
    if pLinkData.cssClass then linkConfigStr += '' + pLinkData.indent + '    "cssClass": "' + pLinkData.cssClass + '",\n'
    if pLinkData.cerberus then linkConfigStr += '' + pLinkData.indent + '    "cerberus": "' + pLinkData.cerberus + '",\n'
    if pLinkData.dataAttributes and pLinkData.dataAttributes.length > 0
      linkConfigStr += '' + pLinkData.indent + '    "dataAttributes": ' + JSON.stringify(pLinkData.dataAttributes) + ',\n'
    linkConfigStr = linkConfigStr.substring 0, linkConfigStr.length - 2
    linkConfigStr += '\n'
    linkConfigStr += pLinkData.indent + '} >\n'
    linkConfigStr += pLinkData.indent + '<@link.linkMozaic ' + configName + '>' + pLinkData.content + '</@link.linkMozaic>'

    pFileData = pFileData.replace pLinkSrc, linkConfigStr

    pFileData


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


  writeDataInFile: (pPath, pData) ->
    console.log ('Overwrite ' + pPath + ' file !!!').yellow
    deferred = q.defer()

    relative = path.relative process.cwd(), pPath
    console.log (' relative path:').blue, relative

    try
      fs.writeFile pPath, pData, 'utf8', (err, data) ->
        if err
          console.log (' Error to write ' + pPath).red, err
          deferred.reject err
        else
          console.log (pPath + ' has been overwritten').green
          deferred.resolve()
    catch error
      console.log 'catch error'.red, error
      deferred.reject error

    deferred.promise


app = new App()
