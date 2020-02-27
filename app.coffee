colors = require 'colors'
prompt = require 'prompt'
fs = require 'fs'
q = require 'q'
#commandLineArgs = require 'command-line-args'
path = require 'path'

module.exports = class App

  commonMacrosPaths: {}

  macroLinkConfigCount: 0
  macroButtonConfigCount: 0

  constructor: ->
    #console.log "process.cwd()".cyan, process.cwd()

    @checkPackageVersion().then (socleVersion) =>
      console.log 'Version de "integration-web-core--socle":'.cyan, (socleVersion).bold.cyan

      @startPrompt()


  startPrompt: ->
    console.log '1. Please choose the processus ("link" or "button")'.blue.bold
    console.log '2. Please choose the extension ("ftl" or "ftlh")'.blue.bold
    prompt.start()

    promptSchema =
      properties:
        type:
          pattern: /^(link|button)$/
          message: 'Type must be "link" or "button"'
          required: true
          default: 'button'
        extension:
          pattern: /^(ftl|ftlh)$/
          message: 'Extension must be "ftl" or "ftlh"'
          required: true
          default: 'ftl'

    prompt.get promptSchema, (err, result) =>
      if err
        console.log "error:".red, err
      else
        console.log 'You\'ve choosen the type:', (result.type).cyan
        console.log 'You\'ve choosen the extension:', (result.extension).cyan
        @startExploration result.type, result.extension


  startExploration: (pType, pExt = 'ftl') ->
    @getFilesByExt(pExt, process.cwd(), yes).then (ftlFiles) =>

      if ftlFiles and ftlFiles.length > 0
        for filePath in ftlFiles
          if filePath.indexOf('templates/macros/common') isnt -1
            if filePath.indexOf('templates/macros/common/' + pType + '.ftl') isnt -1
              @commonMacrosPaths[pType] = filePath
          else
            if pType is 'link'
              @processHref filePath
            if pType is 'button'
              @processButton filePath
      else
        console.log ('No "' + pExt + '" files found!').red


  detectMacroImport: (pFileData, pFilePath, pImportFilename) ->
    regex = new RegExp '<#import "([./]*)macros\/common\/' + pImportFilename + '.ftl" as ([a-zA-Z]*)>', 'gi'
    ftlImports = pFileData.match regex

    if not ftlImports
      pFileData = '<#import "' + path.relative(pFilePath, @commonMacrosPaths[pImportFilename]) + '" as ' + pImportFilename + '>\n' + pFileData

    pFileData


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

            regLink = /([ \t]*)<a[^\>]+>([\w\W]*?)<\/a>/gi
            ahrefResult = regLink.exec ahref
            ahrefIndent = ahrefResult[1]
            ahrefContent = ahrefResult[2]
            iconData = @getIconData ahrefContent
            ahrefContent = ahrefContent.replace /<@[^\>]+icon[^\>]+iconPath=['|"]([^'|"]*)['|"][^\>]*>/gi, ''
            ahrefContent = ahrefContent.trim()

            regexOnlyHeadTag = /<a[^\>]*>/ig
            ahrefOnlyHeadTag = regexOnlyHeadTag.exec ahref
            ahrefHeadTag = ahrefOnlyHeadTag[0]

            ahrefClass = ''
            ahrefHref = ''
            ahrefTarget = '_self'

            attrs = @getAttributes ahrefHeadTag
            attrs.forEach (attr) ->
              if attr.name is 'class' then ahrefClass = attr.value
              if attr.name is 'href' then ahrefHref = attr.value
              if attr.name is 'target' then ahrefTarget = attr.value

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

            macroLinkData =
              href: ahrefHref
              icon: iconData
              #dataTagco: 'todo'
              #dataTcevent: 'todo'
              cerberus: ahrefDataCerberusAttr
              dataAttributes: linkDataAttrs
              target: ahrefTarget
              content: ahrefContent
              indent: ahrefIndent

            if ahrefClass.indexOf('ka-link--s') isnt -1
              macroLinkData.size = 's'

            ahrefClass = ahrefClass.replace 'ka-link--s', ''
            ahrefClass = ahrefClass.replace 'ka-link', ''

            macroLinkData.cssClass = ahrefClass.trim()

            data = @replaceLinkWithMacro pPath, data, ahref, macroLinkData

          @writeDataInFile pPath, data


  processButton: (pPath) ->
    console.log ('\nLook for <button > in ' + pPath + '').blue
    fs.readFile pPath, 'utf8', (err, data) =>
      if err
        console.log 'err:'.red, err
      else
        btnReg = /([ \t]*)<button[^\>]*>([\w\W]*?)<\/button>/gi
        btns = data.match btnReg
        if btns and btns.length > 0
          data = @detectMacroImport data, pPath, 'button'

          btns.forEach (btn) =>
            console.log '\nbtn', btn

            btnRegex = /([ \t]*)<button[^\>]*>([\w\W]*?)<\/button>/gi
            btnResult = btnRegex.exec btn
            btnIndent = btnResult[1]
            btnContent = btnResult[2]
            iconData = @getIconData btnContent
            btnContent = btnContent.replace /<@[^\>]+icon[^\>]+iconPath=['|"]([^'|"]*)['|"][^\>]*>/gi, ''
            btnContent = btnContent.trim()

            regexOnlyHeadTag = /<button[^\>]*>/ig
            btnOnlyHeadTag = regexOnlyHeadTag.exec btn
            btnHeadTag = btnOnlyHeadTag[0]

            btnClass = ''
            btnType = ''

            attrs = @getAttributes btnHeadTag
            attrs.forEach (attr) ->
              if attr.name is 'class' then btnClass = attr.value
              if attr.name is 'type' then btnType = attr.value

            # Get data attributes
            regexBtnDataAttr = /data-([\w]+)=['|"]([^'|"]*)['|"]/ig
            btnDataAttrs = []
            while ((btnDataAttr = regexBtnDataAttr.exec(btnHeadTag)) isnt null)
              if btnDataAttr[1] is 'cerberus'
                btnDataCerberusAttr = btnDataAttr[2]
              else
                btnDataAttrs.push
                  name: btnDataAttr[1]
                  value: btnDataAttr[2]

            macroButtonData =
              type: btnType
              icon: iconData
              #dataTagco: 'todo'
              #dataTcevent: 'todo'
              cerberus: btnDataCerberusAttr
              dataAttributes: btnDataAttrs
              disabled: btnHeadTag.indexOf('disabled') isnt -1
              content: btnContent
              indent: btnIndent

            result = @manageButtonDataFromClass 'ka', btnClass, macroButtonData
            #console.log 'ka result', result
            btnClass = result.btnClass
            macroButtonData = result.macroButtonData

            result = @manageButtonDataFromClass 'mc', btnClass, macroButtonData
            console.log 'mc result', result
            btnClass = result.btnClass
            macroButtonData = result.macroButtonData

            macroButtonData.cssClass = btnClass.trim()

            data = @replaceButtonWithMacro pPath, data, btn, macroButtonData

          @writeDataInFile pPath, data


  manageButtonDataFromClass: (prefix, btnClass, macroButtonData) ->
    if btnClass.indexOf(prefix + '-button--s') isnt -1
      macroButtonData.size = 's'

    if btnClass.indexOf(prefix + '-button--m') isnt -1
      macroButtonData.size = 'm'

    if btnClass.indexOf(prefix + '-button--l') isnt -1
      macroButtonData.size = 'l'

    if btnClass.indexOf('button--bordered') isnt -1
      macroButtonData.style = 'bordered'

    if btnClass.indexOf('button--solid') isnt -1
      macroButtonData.style = 'solid'

    if btnClass.indexOf('primary-02') isnt -1
      macroButtonData.color = 'primary-02'

    if btnClass.indexOf('danger') isnt -1
      macroButtonData.color = 'danger'

    if btnClass.indexOf('neutral') isnt -1
      macroButtonData.color = 'neutral'

    if btnClass.indexOf('icon-only') isnt -1
      if macroButtonData.icon
        macroButtonData.icon.iconOnly = yes

    # ka-button--secondary
    # ka-button--campus
    # ka-button--grey

    if btnClass.indexOf(prefix + '-button--full') isnt -1
      macroButtonData.width = 'full'

    if btnClass.indexOf(prefix + '-link') isnt -1
      macroButtonData.displayStyle = 'link'

      if btnClass.indexOf(prefix + '-link--s') isnt -1
        macroButtonData.size = 's'

      replaceLinkRegex = new RegExp prefix + '-link[-]{0,2}[a-z0-9-]*', 'gi'
      btnClass = btnClass.replace replaceLinkRegex, ''

    replaceRegex = new RegExp prefix + '-button[-]{0,2}[a-z0-9-]*', 'gi'
    btnClass = btnClass.replace replaceRegex, ''

    objToReturn =
      btnClass: btnClass
      macroButtonData: macroButtonData

    objToReturn


  getAttributes: (pHeadTagStr) ->
    # Get all attributes in tag head
    regexAttr = /([\w-]+)=['|"]([^'|"]*)['|"]/ig
    attrs = []
    while ((linkAttr = regexAttr.exec(pHeadTagStr)) isnt null)
      attrs.push
        name: linkAttr[1]
        value: linkAttr[2]

    attrs


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
    if pLinkData.target and pLinkData.target is '_blank'
      linkConfigStr += '' + pLinkData.indent + '    "targetBlank": true,\n'
    if pLinkData.icon and Object.keys(pLinkData.icon).length > 0 then linkConfigStr += '' + pLinkData.indent + '    "icon": ' + JSON.stringify(pLinkData.icon) + ',\n'
    if pLinkData.cssClass then linkConfigStr += '' + pLinkData.indent + '    "cssClass": "' + pLinkData.cssClass + '",\n'
    if pLinkData.cerberus then linkConfigStr += '' + pLinkData.indent + '    "cerberus": "' + pLinkData.cerberus + '",\n'
    if pLinkData.dataAttributes and pLinkData.dataAttributes.length > 0
      linkConfigStr += '' + pLinkData.indent + '    "dataAttributes": ' + JSON.stringify(pLinkData.dataAttributes) + ',\n'

    if linkConfigStr.charAt(linkConfigStr.length - 2) is ','
      linkConfigStr = linkConfigStr.substring 0, linkConfigStr.length - 2
      linkConfigStr += '\n'
    linkConfigStr += pLinkData.indent + '} >\n'
    linkConfigStr += pLinkData.indent + '<@link.linkMozaic ' + configName + '>' + pLinkData.content + '</@link.linkMozaic>'

    pFileData = pFileData.replace pLinkSrc, linkConfigStr

    pFileData


  replaceButtonWithMacro: (pPath, pFileData, pButtonSrc, pButtonData) ->
    lastPathName = @keepLastWord pPath
    lastPathName = lastPathName.replace /[^a-z0-9]*/gi, ''
    configName = lastPathName + @macroButtonConfigCount + 'ButtonConfig'
    @macroButtonConfigCount++

    linkConfigStr = pButtonData.indent + '<#assign ' + configName + ' = {\n'
    if pButtonData.type then linkConfigStr += '' + pButtonData.indent + '    "type": "' + pButtonData.type + '",\n'
    if pButtonData.color then linkConfigStr += '' + pButtonData.indent + '    "color": "' + pButtonData.color + '",\n'
    if pButtonData.style then linkConfigStr += '' + pButtonData.indent + '    "style": "' + pButtonData.style + '",\n'
    if pButtonData.displayStyle then linkConfigStr += '' + pButtonData.indent + '    "displayStyle": "' + pButtonData.displayStyle + '",\n'
    if pButtonData.size then linkConfigStr += '' + pButtonData.indent + '    "size": "' + pButtonData.size + '",\n'
    if pButtonData.disabled then linkConfigStr += '' + pButtonData.indent + '    "disabled": true,\n'
    if pButtonData.width then linkConfigStr += '' + pButtonData.indent + '    "width": "' + pButtonData.width + '",\n'
    if pButtonData.icon and Object.keys(pButtonData.icon).length > 0 then linkConfigStr += '' + pButtonData.indent + '    "icon": ' + JSON.stringify(pButtonData.icon) + ',\n'
    if pButtonData.cssClass then linkConfigStr += '' + pButtonData.indent + '    "cssClass": "' + pButtonData.cssClass + '",\n'
    if pButtonData.cerberus then linkConfigStr += '' + pButtonData.indent + '    "cerberus": "' + pButtonData.cerberus + '",\n'
    if pButtonData.dataAttributes and pButtonData.dataAttributes.length > 0
      linkConfigStr += '' + pButtonData.indent + '    "dataAttributes": ' + JSON.stringify(pButtonData.dataAttributes) + ',\n'

    if linkConfigStr.charAt(linkConfigStr.length - 2) is ','
      linkConfigStr = linkConfigStr.substring 0, linkConfigStr.length - 2
      linkConfigStr += '\n'
    linkConfigStr += pButtonData.indent + '} >\n'
    linkConfigStr += pButtonData.indent + '<@button.buttonMozaic ' + configName + '>' + pButtonData.content + '</@button.buttonMozaic>'

    pFileData = pFileData.replace pButtonSrc, linkConfigStr

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

    #relative = path.relative process.cwd(), pPath
    #console.log (' relative path:').blue, relative

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


  checkPackageVersion: () ->
    deferred = q.defer()

    fs.readFile './package.json', 'utf8', (err, data) ->
      socleRegex = /["|']integration-web-core--socle["|'][ ]*:[ ]*["|'][^#]*#([0-9v.]*)["|']/gi
      packageSocleResult = socleRegex.exec data
      if not packageSocleResult
        deferred.resolve null
      else
        deferred.resolve packageSocleResult[1]

    deferred.promise


app = new App()
