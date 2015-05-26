ObjC.import("CoreGraphics")
ObjC.import("AppKit")

#//////////////////////////////////////////////////
#// Logging
#//////////////////////////////////////////////////

class LoggerConsole
  log: (what) ->
    console.log what

class LoggerFile
  constructor: (@filename = "/tmp/logfile.txt") ->

  log: (what) ->
    File.append(@filename, "#{what}\n")

class Logger
  constructor: (logger=new LoggerConsole())->
    @loggers=[logger]

  addLogger: (logger) ->
    @loggers = @loggers.concat([logger])

  log: (what) =>
    for logger in @loggers
      logger.log(what)

  pp: (what) =>
    @log(Automation.Automation.getDisplayString(what))


logger = new Logger()
#logger.add_logger(new CCCLoggerFile())
pp = logger.pp
log = logger.log

#logger2 = new CCCLogger(new CCCLoggerFile())
#pp2 = logger2.pp

#//////////////////////////////////////////////////
#// Array Utilities
#//////////////////////////////////////////////////

array_flatten = (arr) ->
  arr.reduce ((xs, el) ->
    if Array.isArray el
      xs.concat array_flatten el
    else
      xs.concat [el]), []

array_unique = (arr) ->
  arr.reduce ( (p,c) ->
    if (p.indexOf(c) < 0)
      p.push(c)
    return p
  ), []

#//////////////////////////////////////////////////
#// Keyboard Events
#//////////////////////////////////////////////////

class Keyboard
  constructor: ->
    @shiftDelay = 0.2
    @keyDelay   = 0.05
    @metaKeys =  [
      'Control',
      'Option',
      'Shift',
      'Command',
    ]
    @pressed = @blankModifiers()

    @keymap = {
      a                    : 0x00,
      s                    : 0x01,
      d                    : 0x02,
      f                    : 0x03,
      h                    : 0x04,
      g                    : 0x05,
      z                    : 0x06,
      x                    : 0x07,
      c                    : 0x08,
      v                    : 0x09,
      b                    : 0x0B,
      q                    : 0x0C,
      w                    : 0x0D,
      e                    : 0x0E,
      r                    : 0x0F,
      y                    : 0x10,
      t                    : 0x11,
      1                    : 0x12,
      2                    : 0x13,
      3                    : 0x14,
      4                    : 0x15,
      6                    : 0x16,
      5                    : 0x17,
      Equal                : 0x18,
      9                    : 0x19,
      7                    : 0x1A,
      Minus                : 0x1B,
      8                    : 0x1C,
      0                    : 0x1D,
      RightBracket         : 0x1E,
      o                    : 0x1f,
      u                    : 0x20,
      LeftBracket          : 0x21,
      i                    : 0x22,
      p                    : 0x23,
      l                    : 0x25,
      Quote                : 0x27,
      j                    : 0x26,
      k                    : 0x28,
      Semicolon            : 0x29,
      Backslash            : 0x2A,
      Comma                : 0x2B,
      Slash                : 0x2C,
      n                    : 0x2D,
      m                    : 0x2E,
      Period               : 0x2F,
      Grave                : 0x32,
      KeypadDecimal        : 0x41,
      KeypadMultiply       : 0x43,
      KeypadPlus           : 0x45,
      KeypadClear          : 0x47,
      KeypadDivide         : 0x4B,
      KeypadEnter          : 0x4C,
      KeypadMinus          : 0x4E,
      KeypadEquals         : 0x51,
      Keypad0              : 0x52,
      Keypad1              : 0x53,
      Keypad2              : 0x54,
      Keypad3              : 0x55,
      Keypad4              : 0x56,
      Keypad5              : 0x57,
      Keypad6              : 0x58,
      Keypad7              : 0x59,
      Keypad8              : 0x5B,
      Keypad9              : 0x5C,
      Return               : 0x24,
      Tab                  : 0x30,
      Space                : 0x31,
      Delete               : 0x33,
      Escape               : 0x35,
      Command              : 0x37,
      Shift                : 0x38,
      CapsLock             : 0x39,
      Option               : 0x3A,
      Control              : 0x3B,
      RightShift           : 0x3C,
      RightOption          : 0x3D,
      RightControl         : 0x3E,
      Function             : 0x3F,
      F17                  : 0x40,
      VolumeUp             : 0x48,
      VolumeDown           : 0x49,
      Mute                 : 0x4A,
      F18                  : 0x4F,
      F19                  : 0x50,
      F20                  : 0x5A,
      F5                   : 0x60,
      F6                   : 0x61,
      F7                   : 0x62,
      F3                   : 0x63,
      F8                   : 0x64,
      F9                   : 0x65,
      F11                  : 0x67,
      F13                  : 0x69,
      F16                  : 0x6A,
      F14                  : 0x6B,
      F10                  : 0x6D,
      F12                  : 0x6F,
      F15                  : 0x71,
      Help                 : 0x72,
      Home                 : 0x73,
      PageUp               : 0x74,
      ForwardDelete        : 0x75,
      F4                   : 0x76,
      End                  : 0x77,
      F2                   : 0x78,
      PageDown             : 0x79,
      F1                   : 0x7A,
      LeftArrow            : 0x7B,
      RightArrow           : 0x7C,
      DownArrow            : 0x7D,
      UpArrow              : 0x7E
    }

    @keymap[' ']  = @keymap['Space']
    @keymap['=']  = @keymap['Equal']
    @keymap['-']  = @keymap['Minus']
    @keymap[']']  = @keymap['RightBracket']
    @keymap['[']  = @keymap['LeftBracket']
    @keymap["'"]  = @keymap['Quote']
    @keymap[';']  = @keymap['Semicolon']
    @keymap['\\'] = @keymap['Backslash']
    @keymap[',']  = @keymap['Comma']
    @keymap['/']  = @keymap['Slash']
    @keymap['.']  = @keymap['Period']
    @keymap['`']  = @keymap['Grave']

    @shiftkeymap={}
    for item in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split('')
      @shiftkeymap[item] = @keymap[item.toLowerCase()]

    @shiftkeymap['~'] = @keymap['Grave']
    @shiftkeymap['!'] = @keymap['1']
    @shiftkeymap['@'] = @keymap['2']
    @shiftkeymap['#'] = @keymap['3']
    @shiftkeymap['$'] = @keymap['4']
    @shiftkeymap['%'] = @keymap['5']
    @shiftkeymap['^'] = @keymap['6']
    @shiftkeymap['&'] = @keymap['7']
    @shiftkeymap['*'] = @keymap['8']
    @shiftkeymap['('] = @keymap['9']
    @shiftkeymap[')'] = @keymap['0']
    @shiftkeymap['_'] = @keymap['-']
    @shiftkeymap['+'] = @keymap['=']
    @shiftkeymap['{'] = @keymap['LeftBracket']
    @shiftkeymap['}'] = @keymap['RightBracket']
    @shiftkeymap['|'] = @keymap['Backslash']
    @shiftkeymap[':'] = @keymap['Semicolon']
    @shiftkeymap['"'] = @keymap['Quote']
    @shiftkeymap['<'] = @keymap['Comma']
    @shiftkeymap['>'] = @keymap['Period']
    @shiftkeymap['?'] = @keymap['Slash']


  blankModifiers: ->
    ret = {}
    for i in @metaKeys
      ret[i] = false
    return ret

  event: (key, state) ->
    if key of @keymap
      code = @keymap[key]
    else if key of @shiftkeymap
      code = @shiftkeymap[key]
    else
      throw new Error("Invalid key specified: '#{key}'")
    event = $.CGEventCreateKeyboardEvent($.NULL, code, state)
    $.CGEventPost($.kCGHIDEventTap, event)

  down: (key) ->
    @event(key, true)

  up: (key) ->
    @event(key, false)

  mapModifier: (what) ->
    what=what.toLowerCase()
    if what == 'c' or what == 'ctl' or what == 'cntl' or what == 'control'
      return 'Control'
    else if what == 'a' or what == 'alt' or
          what == 'o' or what == 'opt' or what == 'option'
      return 'Option'
    else if what == 's' or what == 'shift'
      return 'Shift'
    else if what == 'm' or what == 'command' or what == "cmd"
      return 'Command'
    else
      throw new Error("Invalid modifier specified: '#{what}'")

  pressModifiers: (modifiers=@blankModifiers())->
    changed = false
    old = @pressed
    for mod in @metaKeys
      state = @pressed[mod]
      desired = modifiers[mod]
      if desired != state
        changed = true
        @pressed[mod] = desired
        @event(mod, desired)
    ret = [ changed, old ]
    return ret

  send: (key, restore=true) ->
    if Array.isArray(key)
      for item in key
        @send(item)
      return

    if key == '-' or key == ' '
      parts=[key]
    else
      pattern = /\s\s*/
      parts = key.split(pattern)
      if parts.length > 1
        for item in parts
          @send(item)
        return
    
      parts = parts[0].split('-',2)
      key = parts[parts.length-1]
  
    modifiers=@blankModifiers()
    if parts.length > 1
      for mod in parts[0].split(',')
        modifiers[@mapModifier(mod)] = true
  
    if key of @shiftkeymap
      modifiers['Shift'] = true
  
    [ changed, previousModifiers ] = @pressModifiers(modifiers)
    if changed
      delay(@shiftDelay)

    @down(key)
    @up(key)
  
    if restore
      @pressModifiers(previousModifiers)

  type: (string) ->
    for key in string.split('')
      @send(key, false)
      delay(@keyDelay)
    @pressModifiers()

#//////////////////////////////////////////////////
#// Mouse Events
#//////////////////////////////////////////////////

class Mouse
  @position: ->
    event = $.CGEventCreate($.NULL)
    location = $.CGEventGetLocation(a)
    return location

  @makePoint: (x, y) ->
    if y?
      point = $.CGPointMake(x,y)
    else if x?
      point = x
    else
      point = @position()
    return point

  @moveTo: (x, y) ->
    point = @makePoint(x,y)
    event = $.CGEventCreateMouseEvent($.NULL,
              $.kCGEventMouseMoved,
              point,
              $.kCGMouseButtonLeft)
    $.CGEventPost($.kCGHIDEventTap, move)

  @clickAt: (x, y, clicks=1, delayAmount=0.1) ->
    point = @makePoint(x,y)
    event = $.CGEventCreateMouseEvent($.NULL,
              $.kCGEventMouseMoved,
              point,
              $.kCGMouseButtonLeft)
    $.CGEventPost($.kCGHIDEventTap, event)
    for i in [1..clicks]
      $.CGEventSetIntegerValueField(event, $.kCGMouseEventClickState, i)
      $.CGEventSetType(event, $.kCGEventLeftMouseDown)
      $.CGEventPost($.kCGHIDEventTap, event)
      $.CGEventSetType(event, $.kCGEventLeftMouseUp)
      $.CGEventPost($.kCGHIDEventTap, event)
      delay(delayAmount)

  @dragStart: (x, y) ->
    point = @makePoint(x, y)
    event = $.CGEventCreateMouseEvent($.NULL,
                $.kCGEventLeftMouseDown,
                point,
                $.kCGMouseButtonLeft)
    $.CGEventPost($.kCGHIDEventTap, event)

  @dragTo: (x, y) ->
    point = @makePoint(x, y)
    event = $.CGEventCreateMouseEvent($.NULL,
                $.kCGEventLeftMouseDragged,
                point,
                $.kCGMouseButtonLeft)
    $.CGEventPost($.kCGHIDEventTap, event)

  @dragEnd: (x, y) ->
    @dragTo(x,y)
    point = @makePoint(x, y)
    event = $.CGEventCreateMouseEvent($.NULL,
                $.kCGEventLeftMouseDown,
                point,
                $.kCGMouseButtonLeft)
    $.CGEventPost($.kCGHIDEventTap, event)

#//////////////////////////////////////////////////
#// Pasteboard
#//////////////////////////////////////////////////

class Pasteboard
  @set: (string) ->
    pasteboard = $.NSPasteboard.generalPasteboard
    pasteboard.clearContents
    pasteboard.writeObjects($([$(string)]))
    # or ...
    #textarray = $.NSArray.arrayWithObject($(string))
    #pasteboard.writeObjects(textarray)

  @get: ->
    pasteboard = $.NSPasteboard.generalPasteboard
    contents = pasteboard.stringForType($("public.utf8-plain-text"))
    return contents.js

#//////////////////////////////////////////////////
#// Mac Application base class
#//////////////////////////////////////////////////

class MacApp
  activate: ->
    @app().activate()

  events: ->
    unless @event_handle?
      @event_handle = Application('System Events').processes[@appName]
    return @event_handle

  app: ->
    unless @app_handle?
      @app_handle = Application(@appName)
    return @app_handle

  @midPoint: (node)->
    pos = node.position()
    size = node.size()
    return [ pos[0] + size[0]/2, pos[1] + size[1]/2 ]

  @uiParent: (node, upLevels=1) ->
    for i in [1..upLevels]
      node = node.attributes['AXParent'].value()
    return node

  @midpointContained: (node, container, fudge) ->
    x = node.position()[0]+node.size()[0]/2
    y = node.position()[1]+node.size()[1]/2
    return @pointContained(x, y, container, fudge)

  @pointContained: (x, y, container, fudge=0) ->
    container_pos = container.position()
    container_size = container.size()
    container_size[0] -= fudge
    container_size[1] -= fudge

    if container_pos[0] > x
      return false
    if container_pos[0] + container_size[0] < x
      return false
    if container_pos[1] > y
      return false
    if container_pos[1] + container_size[1] < y
      return false
    return true

  searchUIElementsWhose: (whosedict, node=@events().windows) ->
    whosedict = array_flatten([ whosedict ])
    for criteria in whosedict
      node = @searchUIElements node, (obj, arg)->
        return obj.whose(criteria)
      unless node?
        break
    return node

  searchUIElements: (node=@events().windows, callback, arg, depth=10)->
    node = node.uiElements
    for i in [1..depth]
      ret = callback(node, arg)
      ret = array_flatten(ret())
      if ret.length > 1
        throw new Error("searchUIElements: Too many matches #{ret.length}")
      else if ret.length == 1
        return ret[0]
      node = node.uiElements
    return null

  menuCommandLeaf: (menuText, depth=5) ->
    node = @events().menuBars.menuBarItems
    for i in [1..depth]
      children = node.whose
        title: menuText
      items = array_flatten(children())
      if items.length > 0
        items[0].click()
        return
      node = node.menus.menuItems

    throw new Error("Unable to find menu item: #{menuText}")

  menuCommand: (menuText) ->
    path = menuText.split('->')
    node = @events().menuBars.menuBarItems.whose
      title: path.shift()
    for title in path
      node = node.menus.menuItems.whose
        title: title
    items = array_flatten(node())
    if items.length == 1
      items[0].click()
      return
    throw new Error("Menu item found #{items.length} times: #{menuText}")

  dialogNode: ->
    items = array_flatten(@events().windows.whose({ subrole: 'AXDialog' })())
    if items.length != 1
      throw new Error("Found #{items.length} dialogs instead of one")
    return items[0]

  closeDialog: ->
    node = @searchUIElementsWhose { subrole: 'AXCloseButton' }, @dialogNode()
    node.click()

  cut: ->
    @menuCommand("Edit->Cut")

  copy: ->
    @menuCommand("Edit->Copy")

  paste: ->
    @menuCommand("Edit->Paste")

#//////////////////////////////////////////////////
#// Keyboard Maestro
#//////////////////////////////////////////////////

class KeyboardMaestroEngine extends MacApp
  constructor: ->
    @appName = 'Keyboard Maestro Engine'
    @vars = @app().variables

  create: (name) ->
    try
      @vars[name].name()
    catch e
      @vars.push(@app.Variable
        name: name
      )

  get: (name) ->
    @create(name)
    return @vars[name].value()

  set: (name, newValue) ->
    @create(name)
    return @vars[name].value = newValue

#//////////////////////////////////////////////////
#// Safari
#//////////////////////////////////////////////////

class SafariApp extends MacApp
  constructor: ->
    @appName = 'Safari'

  javascript: (script) ->
    return @app().doJavaScript(script, { in: @app().windows[0].currentTab })

  # Useful codes
  # left=37, right=39, up=38, down=40, enter=13, esc=27
  # keyup, keydown, keypress
  sendKeyCode: (code, eventType='keyup') ->
    script = """
        function sendCode(keyCode, eventType)
        {
            eventType = eventType || 'keyup';
            var eventObj = document.createEventObject ?
                document.createEventObject() : document.createEvent('Events');
          
            if(eventObj.initEvent){
              eventObj.initEvent('keyup', true, true);
            }
          
            eventObj.keyCode = keyCode;
            eventObj.which = keyCode;

            var el = document.body;
            el.dispatchEvent ? el.dispatchEvent(eventObj) :
              el.fireEvent('onkeydown', eventObj);
        }
        sendCode(#{code}, '#{eventType}')
"""
    @javascript(script)

  currentURL: ->
    return @javascript("window.location.href")

  goToURL: (url)->
    @javascript("window.location.href='#{url}'")
    delay(1)


#//////////////////////////////////////////////////
#// NextNum
#//////////////////////////////////////////////////

class NextNum
  constructor: (@countfile=Path('count.txt').toString(),
                @textfile=Path('program.txt').toString(),
                @separator='|')->
    @countLoad()
    @fileLoad()

  fileLoad: ->
    lines = File.readlines(@textfile)
    @data = lines.map ((currentValue, index, array) ->
      return currentValue.split(@separator)
    ), @

  current: ->
    return @count

  countLoad: ->
    data = File.read(@countfile)
    @count = parseInt(data)
    return @count

  countSave: ->
    File.write_atomic(@countfile, "#{@count}\n")

  countAdvance: ->
    @count += 1
    @countSave()

  countAdvanceTemp: ->
    @count += 1

  countPrevious: ->
    @count -= 1
    @countSave()

  countPreviousTemp: ->
    @count -= 1

  field: (column) ->
    column = parseInt(column)
    return @data[@count][column]

#//////////////////////////////////////////////////
#// Dir
#//////////////////////////////////////////////////

class Dir
  @chdir: (path)->
    manager = $.NSFileManager.defaultManager
    manager.changeCurrentDirectoryPath(path)

  @home: ->
    return $.NSHomeDirectory().js

#//////////////////////////////////////////////////
#// File
#//////////////////////////////////////////////////

class File
  @write_atomic: (filename, string)->
    error=$()
    $(string).writeToFileAtomicallyEncodingError(
      filename,
      $.YES,
      $.NSUTF8StringEncoding,
      error)
    if not error.isNil()
      throw new Error("File.write_atomic: #{error.localizedDescription.js}")

  @write: (filename, string, offset=0, options)->
    manager = $.NSFileManager.defaultManager
    if not manager.fileExistsAtPath(filename)
      manager.createFileAtPathContentsAttributes(filename, $.nil, $.nil)
    handle = $.NSFileHandle.fileHandleForWritingAtPath(filename)
    if handle.isNil()
      throw new Error("Unable to open file #{name}")
    handle.seekToFileOffset(offset)
    handle.writeData($(string).dataUsingEncoding($.NSUTF8StringEncoding))
    handle.close

  @append: (filename, string, options)->
    manager = $.NSFileManager.defaultManager
    if not manager.fileExistsAtPath(filename)
      manager.createFileAtPathContentsAttributes(filename, $.nil, $.nil)
    handle = $.NSFileHandle.fileHandleForWritingAtPath(filename)
    if handle.isNil()
      throw new Error("Unable to open file #{name}")
    handle.seekToEndOfFile
    handle.writeData($(string).dataUsingEncoding($.NSUTF8StringEncoding))
    handle.close

  @read: (name, length=null, offset=0, options)->
    handle = $.NSFileHandle.fileHandleForReadingAtPath(name)
    if handle.isNil()
      throw new Error("Unable to open file #{name}")
    handle.seekToFileOffset(offset)
    data = null
    if length?
      data = handle.readDataOfLength(length)
    else
      data = handle.readDataToEndOfFile

    string = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding)
    handle.close
    return string.js

  @readlines: (name, sep="\n", options)->
    string = @read(name).trim()
    return string.split(sep)

  @delete: (names...) ->
    manager = $.NSFileManager.defaultManager
    for filename in names
      error = $()
      manager.removeItemAtPathError(filename, error)

  @exist: (filename) ->
    manager = $.NSFileManager.defaultManager
    manager.fileExistsAtPath(filename)

  @rename: (old_name, new_name) ->
    manager = $.NSFileManager.defaultManager
    error = $()
    rc = manager.moveItemAtPathToPathError(old_name, new_name, error)
    if not rc
      throw new Error("File.rename: #{error.localizedDescription.js}")

#//////////////////////////////////////////////////
#// Shell
#//////////////////////////////////////////////////

class Shell
  @run: (command) ->
    task = $.NSTask.alloc.init
    task.setLaunchPath("/bin/sh")
    task.setArguments($(["-c", command]))

    pipe = $.NSPipe.pipe
    task.setStandardOutput(pipe)

    readhandle = pipe.fileHandleForReading

    task.launch

    data = readhandle.readDataToEndOfFile
    string = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding)
    return string.js.trim().split("\n")

#//////////////////////////////////////////////////
#// Final Cut
#//////////////////////////////////////////////////

class FinalCutProApp extends MacApp
  constructor: ->
    @appName = 'Final Cut Pro'
    @keyboard = new Keyboard()

  # Activate Panes
  activatePane: (name) ->
    @menuCommand("Window->Go to->#{name}")

  activateTimeline: ->
    @activatePane('Timeline')

  activateBrowser: ->
    @activatePane('Browser')

  # Move in Timeline
  timelineBeginning: ->
    @activateTimeline()
    @menuCommand('Mark->Go to->Beginning')

  timelineEnd: ->
    @activateTimeline()
    @menuCommand('Mark->Go to->End')

  nextEdit: ->
    @menuCommand('Mark->Next->Edit')

  previousEdit: ->
    @menuCommand('Mark->Previous->Edit')

  nextFrame: ->
    @menuCommand('Mark->Next->Frame')

  previousFrame: ->
    @menuCommand('Mark->Previous->Frame')

  timelineMoveTo: (string) ->
    @activateTimeline()
    delay(0.05)
    button = @searchUIElementsWhose
      role: 'AXButton',
      help: 'Move Playhead or Change Duration'
    delay(0.05)
    button.click()
    delay(0.05)
    @keyboard.type(string)
    delay(0.05)
    @keyboard.send('Return')

  # Timeline utility
  selectClip: ->
    @menuCommand('Edit->Select Clip')

  addAllTransitions: ->
    @activateTimeline()
    delay(0.2)
    @keyboard.send('Cmd-a')
    delay(0.2)
    @keyboard.send('Cmd-t')

  # Titiling helpers
  addLowerThird: (titlename='Gradient - Center') ->
    @activate()
    @activateTimeline()

    title = @searchUIElementsWhose
      title: titlename

    scrollarea = MacApp.uiParent(title, 2)

    if not MacApp.midpointContained(title, scrollarea)
      throw new Error("Title #{titlename} is not currently visible")

    delay(0.2)
    mid = MacApp.midPoint(title)
    Mouse.clickAt(mid[0], mid[1], 2)

  openReplaceTitleText: ->
    @menuCommandLeaf('Find and Replace Title Text...')
    delay(0.5)

  replaceTitleText: (oldValue, newValue) ->
    orig = @searchUIElementsWhose
      accessibilityDescription: "The text to find in the project."
    repl = @searchUIElementsWhose
      accessibilityDescription:
        "Replacement text for instances of text found in the project."

    orig.value = oldValue
    repl.value = newValue

    replace_all = @searchUIElementsWhose
      name: "Replace All"
    replace_all.click()
    delay(0.1)

  # Render output files
  renderProject: (choice='Apple Devices 1080p…', suffix, tags) ->
    @menuCommand("File->Share->#{choice}")
    delay(0.5)

    if tags?
      # No identifying information for the tags field
      a = @events().windows.groups.scrollAreas.textFields()
      a = array_flatten(a)
      a[3].value = tags

    nextButton = @searchUIElementsWhose
      title: 'Next…'
    nextButton.click()
    delay(0.5)

    if suffix?
      node = @searchUIElementsWhose { role: 'AXTextField' }
      node.value = node.value() + suffix

    saveButton = @searchUIElementsWhose
      title: 'Save'
    saveButton.click()
    delay(0.5)

  displayTitle: ->
    @timelineMoveTo('6;')
    delay(0.5)

  renderThumbnail: (tags=undefined)->
    @displayTitle()
    @renderProject('Save Current Frame…', null, tags)


  newProject: (name) ->
    @menuCommand('File->New->Project…')

    if name?
      node = @searchUIElementsWhose
        accessibilityDescription: 'name'
      node.value = name

    button = @searchUIElementsWhose
      title: 'Ok'
    button.click()

  # Advance through clip list
  nextClip: ->
    @activateBrowser()
    scrollArea = @searchUIElementsWhose [
      { description: 'Organizer list split view' },
      { description: 'Organizer filmlist scroll view' }
    ]

    clipArea = @searchUIElementsWhose [
      { description: 'Organizer filmlist outline view' }
    ], scrollArea

    selectedRow = @searchUIElementsWhose {
      role: 'AXRow',
      selected: true
    }, clipArea

    current = selectedRow.attributes['AXIndex'].value()
    if current + 1 >= clipArea.rows().length
      return false

    newRow = clipArea.rows[current+1]()
    newRow.select()

    pos = newRow.position()
    size = newRow.size()
    if not MacApp.pointContained(pos[0], pos[1]+size[1]/2, scrollArea, 15)
      nextPage = @searchUIElementsWhose [
        { description: 'Organizer list split view' },
        { description:  'Organizer filmlist vertical scroller' }
        { description:  'increment page button' }
      ]
      nextPage.click()
    delay(0.2)
    @menuCommand('Clip->Open in Timeline')
    return true

  traverseClips: (callback, limit=100, delaytime=1) ->
    while limit > 0
      limit -= 1
      callback(arg)
      unless @nextClip()
        break
      delay(delaytime)



  # Render output files
  renderThumbs: (limit=100, tags=undefined) ->
    @traverseClips =>
      @renderThumbnail(tags)
    , limit

  renderVideos: (limit=100, tags=undefined) ->
    @traverseClips =>
      @renderProject('Apple Devices 1080p…', '1080p', tags)
      #@renderProject('Apple Devices 720p…', '720p', @tags())
    , limit

  # Remove last bit of footage to make new clip
  cutLastFootage: ->
    @timelineEnd()
    @previousFrame()
    @selectClip()
    @cut()

  pasteLastFootage: ->
    @timelineBeginning()
    @paste()
    @timelineBeginning()

class SSOAFcpTitle
  constructor: (@additionalText='') ->
    @nextNum = new NextNum
    @fcp = new FinalCutProApp()

  next: ->
    @nextNum.countAdvance()

  makeNextProject: ->
    @next()
    name=@filename()
    @fcp.cutLastFootage()
    @fcp.newProject name
    @fcp.pasteLastFootage()


  addTitle: ->
    @fcp.timelineMoveTo('5;')
    @fcp.addAllTransitions()
    @fcp.addLowerThird()
    @fcp.openReplaceTitleText()
    @fcp.replaceTitleText "Name", @title1()
    @fcp.replaceTitleText "Description", @title2()
    @fcp.closeDialog()

  displayTitle: ->
    @fcp.timelineMoveTo('6;')
    delay(0.5)

  tags: ->
    return "Violin, Concert, Recital, SSOA"

  filename: ->
    # Find out how to format numbers using sprintf or initWithFormat
    # Right now vardic parametrs are crippled
    count = @nextNum.current()
    str = "0000"+count
    str = str[str.length-2..str.length]
    return str + '-' + @nameFirst()

  nameFirst: ->
    return @name().split(' ').shift()

  title1: ->
    str = @nameFirst()
    if @additionalText and @additonalText != ''
      str += " - #{@additionalText}"
    return str

  title2: ->
    str = @song()
    if @composer() != ''
      str += " / #{@composer()}"
    return str

  name: ->
    return @nextNum.field(2)

  song: ->
    return @nextNum.field(0)

  composer: ->
    return @nextNum.field(1)

class UTSPFcpTitle
  constructor: (@additionalText='') ->
    @nextNum = new NextNum
    @fcp = new FinalCutProApp()

  next: ->
    @nextNum.countAdvance()

  addTitle: ->
    #@fcp.nextFrame()
    #@fcp.previousEdit()
    @fcp.timelineMoveTo('5;')
    @fcp.addLowerThird()
    @fcp.openReplaceTitleText()
    @fcp.replaceTitleText "Name", @title1()
    @fcp.replaceTitleText "Description", @title2()
    @fcp.closeDialog()
    @fcp.timelineMoveTo('-1;')

  makeNextProject: ->
    @fcp.newProject @filename()
    @fcp.pasteLastFootage()

  makeAndTitleNextProject: ->
    @fcp.cutLastFootage()
    @fcp.newProject @filename()
    @fcp.pasteLastFootage()
    delay(1)
    @addTitle()

  tags: ->
    return "Violin, Concert, Recital, UTSP"

  filename: ->
    # Find out how to format numbers using sprintf or initWithFormat
    # Right now vardic parametrs are crippled
    count = @nextNum.current()
    str = "0000"+(count+1)
    str = str[str.length-2..str.length]

    parts=[str]
    parts.push( @group().split(' ').shift() )
    parts = parts.concat(@song().split(' '))

    return parts.join('-')

  title2: ->
    str = @group()
    if @additionalText and @additonalText != ''
      str += " - #{@additionalText}"
    return str

  title1: ->
    str = @song()
    if @composer() != ''
      str += " / #{@composer()}"
    return str

  group: ->
    return @nextNum.field(0)

  song: ->
    return @nextNum.field(1)

  composer: ->
    return @nextNum.field(2)

class SmugMugSite
  constructor: ->
    @safari = new SafariApp()

  yui_click: (selector) ->
    @safari.javascript """
      function clickit(sel) {
          YUI().use("node", function(Y) {
              var evt = document.createEvent("MouseEvents");
              evt.initMouseEvent("click", true, true, window,
                0, 0, 0, 0, 0, false, false, false, false, 0, null);
              Y.one(sel)._node.dispatchEvent(evt);
          });
      }
"""
    @safari.javascript "clickit('#{selector}')"

  uploadThumbnails: (limit=100) ->
    for index in [1..limit]
      start_url = @safari.currentURL()

      try
        page = new UploadThumbPage1(@)
        while page?
          console.log "Uploading Thumbnail ##{index} #{page.description()}"
          page = page.action()

        for i in [1..60]
          end_url = @safari.currentURL()
          if start_url != end_url
            break
          delay 1

        if start_url == end_url
          console.log "URLs match, exiting"
          return


          return
      catch error
        console.log "Failed upload: #{error}"
        @safari.goToURL(start_url)


class UploadThumbPage1
  constructor: (@site) ->

  description: ->
    return "Page1"

  ready: ->
    ret = @site.safari.javascript "document.readyState"
    return ret

  wait_for_load: ->
    for i in [1..60]
      if @ready() == "complete"
        return
      delay(1)
    throw new Error("Timeout waiting for #{@description}")

  action: ->
    @wait_for_load()

    delay(0.2)
    @site.yui_click('button[data-value="tools"]')
    delay(0.2)
    @site.yui_click('a[data-item-id="ImageEditReplace"]')

    return new UploadThumbPage2(@site)

class UploadThumbPage2
  constructor: (@site) ->

  description: ->
    return "Page2"

  findVideoname: ->
    ret = @site.safari.javascript """
      var a=null;
      YUI().use('node', function(Y) {
        fields=Y.all('table tbody tr td span[class="foreground"]');
        a=fields._nodes[0].parentNode.nextElementSibling.textContent.trim()
      });
      a;
    """
    return ret

  waitForVideoname: ->
    videoname = null
    for i in [1..60]
      videoname = @findVideoname()
      if videoname?
        break
      delay(1)

    unless videoname?
      throw new Error("Unable to find videoname on page")

    return videoname

  openFileDialog: ->
    button = @site.safari.searchUIElementsWhose
      subrole: 'AXFileUploadButton'
    button.click()

  selectThumbnailFile: (videoname) ->
    videoprefix = videoname.split('-').shift()+'-'
    ret = @site.safari.searchUIElementsWhose [
            { accessibilityDescription: 'open' },
            { _and: [
                { role: 'AXOutline' },
                { description: 'list view' }
            ]},
            { _and: [
                { role: 'AXTextField' },
                { value: { _beginsWith: videoprefix } }
            ]}
          ]

    ret = MacApp.uiParent(MacApp.uiParent(ret))
    ret.select()

    return ret

  selectChooseButton: ->
    button = @site.safari.searchUIElementsWhose
      _and: [
        {title: 'Choose'},
        {role: 'AXButton'}
      ]
    button.click()

  submitThumb: ->
    @site.safari.javascript("document.replace_images.submit()")

  action: ->
    videoname = @waitForVideoname()
    @openFileDialog()
    delay(0.5)
    @selectThumbnailFile(videoname)
    @selectChooseButton()

    @submitThumb()

    return new UploadThumbPage3(@site)

class UploadThumbPage3
  constructor: (@site) ->

  description: ->
    return "Page3"

  wait_for_load: ->
    ret = null
    for i in [1..60]
      ret = @ready()
      if ret?
        return ret
      delay(1)
    throw new Error("Timeout waiting for #{@description}")

  ready: ->
    ret = @site.safari.javascript """
      a=null;
      for (var i = 0; i < document.links.length; ++i) {
        if (document.links[i].textContent.match(/return to what/)) {
          a = document.links[i];
        }
      }
      if (a) {
        a = a.href;
      }
      a;
    """
    return ret

  action: ->
    url = @wait_for_load()
    @site.safari.goToURL(url)
    return new UploadThumbPage4(@site)

class UploadThumbPage4
  constructor: (@site) ->

  description: ->
    return "Page4"

  ready: ->
    return @site.safari.javascript "document.readyState"

  wait_for_load: ->
    for i in [1..60]
      if @ready() == "complete"
        return
      delay(1)
    throw new Error("Timeout waiting for #{@description}")


  action: ->
    @wait_for_load()
    delay(1)
    @site.safari.sendKeyCode(39)
    delay(1)
    return null



#Dir.chdir(Dir.home+"/work/ssoa")

eval(File.read('lib/optparse-js/lib/optparse.js'))
ObjC.bindFunction('exit', ['void', ['int']])

run = (argv) ->
  additional_text = "Spring 2015"
  limit = 100
  tags = "Violin, Concert, Recital, UTSP, Spring 2015"
  switches = [
      [ '-h', '--help', 'Shows help sections' ]
      [ '--ssoanextproject', 'Split multicam clip into new project (SSOA)' ]
      [ '--utsptitle', 'Add Title for (UTSP)' ]
      [ '--utspprevtitle', 'Add (Previous) Title for (UTSP)' ]
      [ '--utspproject', 'Make new project for (UTSP)' ]
      [ '--renderthumbs', 'Render Thumbnails' ]
      [ '--rendervideos', 'Render Videos' ]
      [ '--nextclip', 'Next Clip' ]
      [ '--limit NUMBER', 'Limit' ]
      [ '--tags STRING', 'Tags to apply' ]
      [ '--testnextnum', 'NextNum' ]
      [ '--uploadthumbs', 'Upload Thumbnails to SmugMug' ]
  ]

  parser = new optparse.OptionParser(switches)

  parser.on (opt)->
    throw new Error("No handler was defined for option: #{opt}")

  parser.on 'help', ->
    console.log parser.toString()
    $.exit(0)

  parser.on 'ssoanextproject', ->
    titler = new SSOAFcpTitle(additional_text)
    titler.fcp.activate()
    titler.addTitle()
    titler.makeNextProject()

  parser.on 'utsptitle', ->
    titler = new UTSPFcpTitle()
    titler.fcp.activate()
    titler.addTitle()
    #titler.next()

  parser.on 'utspprevtitle', ->
    titler = new UTSPFcpTitle()
    titler.fcp.activate()
    titler.nextNum.countPreviousTemp()
    titler.addTitle()
    #titler.next()

  parser.on 'utspproject', ->
    titler = new UTSPFcpTitle()
    titler.fcp.activate()
    titler.makeAndTitleNextProject()
    titler.next()

  parser.on 'nextclip', ->
    fcp = new FinalCutProApp()
    fcp.nextClip()

  parser.on 'limit', (name, value)->
    limit=value

  parser.on 'tags', (name, value)->
    tags=value

  parser.on 'renderthumbs', ->
    fcp = new FinalCutProApp()
    fcp.activate()
    fcp.renderThumbs(limit, tags)

  parser.on 'rendervideos', ->
    fcp = new FinalCutProApp()
    fcp.activate()
    fcp.renderVideos(limit, tags)

  parser.on 'testnextnum', ->
    nextNum = new NextNum
    console.log(nextNum.current())
    nextNum.countAdvance()

  parser.on 'uploadthumbs', ->
    site = new SmugMugSite()
    site.uploadThumbnails(limit)

  out = parser.parse(argv)


