# Violin Video Helper

This directory contains scripts to make my workflow for editing footage from
violin recitals and concerts and managing them on SmugMug easier.

I record the entire footage of a concert or recital, import them into Final Cut
Pro X, make a multicam clip and then start chopping it into smaller pieces,
usually per song.  The scripts here allow me to create a file with all of the
title information in it and have it automatically add the title or create the
appropriately named project for the next clip.

This uses the OS X feature "Javascript for Automation" (JAX) because I just
can't get my head around AppleScript.  The code is a bit of shell scripting to
hook it easily into a Keyboard Maestro shortcut, and a CoffeeScript file which
gets compiled to JavaScript.

Run the script with:
  ./run_action <actionname> [options]

Right now it expects a file called 'program.txt' to contain the title information.  And a file called 'count.txt' to contain the current title
to be applied.

The run_action script will attempt to run the command in tmux window 0:0, or
the current pane if invoked from within TMUX.  That's because it's nice to see
error messages when being invoked from Keyboard Maestro.

## License
This is all available under the Apache License

## Actions

###Action: ssoanextproject
Expects the program.txt file to contain the information

  song|composer|performer

It will add a title at the 5 second mark, cut the last piece of footage off the
current project, create a new project with the next file name, and paste the
footage there.

###Action: utsptitle
Expects the program.txt file to contain the information

  group|song|composer

It will add a title at the 5 second mark

###Action: utspprevtitle
It will add the "previous" title.  Useful for when something went wrong adding the title.


###Action: utspnextproject
It will cut the last piece of footage, create a new project with it, and title it.  


###Action: nextclip
It will move to the next final cut pro X clip.  Make sure you've select Smart Folders and the Projects in the Browser.

###Action: renderthumbs
It will render thumbnails for the videos.  Select the first video you want to thumbnail, and then it will run until the last video or limit is reached.  Render the first video by hand to set the output directory.

###Action: rendervideos
It will render videos at 1080p.  Select the first video you want to output, it will run until the last video or limit is reached.  Render the first video by hand to set the output directory.

###Action: uploadthumbs
Log into your smugmug account.  Go the gallery you want to add thumbnails to.  Add the first thumbnail by hand to set the thumbnail source directory.

###Option: limit
Some actions will limit the number times they will operate.

###Option: tags
When rendering video projects this will set tags on the output file


## Classes
### CCCLogger
Provides:

  1. log - log something
  2. pp - log formatted description
  3. addLogger - add another logging destination

Use CCCLoggerConsole and CCCLoggerFile as destinations

### Keyboard
Allows you to enter text as if typed on the keyboard:
Provides:

  1. type(string) - types a string
  2. send(key or array of keys) - takes strings in the form of 'C-m' or 'Opt,Cmd-f'.  Modifiers can be 'Cmd', 'Opt', 'Ctrl' or 'Shift'.

### Mouse
Allows you to emulate a mouse
Provides:

  1. position - return current mouse location
  2. moveTo(x,y) - move mouse
  3. clickAt(x,y,times,delay) - click on a spot one or more times (double click)
  4. dragStart(x,y) - start left button drag
  4. dragTo(x,y) - continue left button drag
  4. dragEnd(x,y) - end left button drag

### Pasteboard
Provides:

  1. set(string) - set clipboard to string
  2. get - return utf8-plain-text from clipboard

### MacApp
Wrapper for an application

  1. activate - activate application
  2. events - get 'System Events' process for app
  2. app - get application handle
  2. searchUIElementsWhose(whosedict, node) - search down through UI tree of application to find a node which matches criteria.  node can be specified for the start of the search.  whosedict can also be an array of dictionaries which it will search for, finding the first, and then using that as the root to continue the search with the next.
  3. searchUIElements(node, callbac, arg, depth) - search for a UI element using a callback
  3. menuCommandLeaf(menutText, depth) - activate menu command based on the terminal text e.g. 'Paste Selection'
  3. menuCommand(menuText) - activate menu command based on full path, e.g. 'Edit->Find->Find Next'
  4. dialogNode - find dialog box for app.  Useful to supply root for searchUIElementWhose
  5. closeDialog - click the red close button for the dialog box
  5. cut/copy/paste - just issues the menu Edit-> command

It also has some class helper functions

  1. midPoint(node) - find center of UI element
  1. uiParent(node) - find parent of UI element
  1. midpointContained(node, container, fudge) - returns true if midpoint of node is in container
  1. pointContained(x, y, container, fudge) - returns true if point is within container

### KeyboardMaestroEngine
Provides:

  1. get(name) - get value of a Keyboard Maestro Variable
  1. set(name, newValue) - set/create value

### SafariApp
Provides:

  1. javascript(script) - Runs javascript in current tab of frontmost window
  2. sendKeyCode - fakes a keyboard event.  This allows you to "type" in a window when it's not in the foreground.  So you can use your computer for other things!
  3. currentURL - returns current url
  3. goToURL - go to URL

### NextNum
This provides an interface to a file that contains records of information.  It's a super dumb read only database.

  1. new NextNum(countfile,textfile,separator) - initialize it
  2. current - return current record number
  2. countAdvance - advance the counter
  2. countAdvanceTemp - advance the counter, but don't save it to the persistant file
  2. countPrevious - decrement the counter
  2. countPreviousTemp - decrement the counter, but don't save it to the persistant file
  2. field(column) - Return data from column of the current record

### Dir
Provides:

  1. chdir(path) - change directory
  1. home - returns path to users Home directory

### File
Interface to read/write files.

  1. write_atomic (filename,string) - writes string to filename
  1. write(filename,string,offset,options) - write data to file at offset, creates file if it doesn't exist
  1. append(filename,string,options) - append string to filename
  1. read(filename,length,offset,options) - read data from file
  1. readlines(filename,separator,options) - read data from file as an array of lines
  1. delete(filename,...) - delete files
  1. exist(filename) - returns true if file exists
  1. rename(old,new) - rename file

### Shell
Returns the output of a shell command

  1. run(command) - returns stdout of command


### FinalCutProApp
Activate Panes to work in:

  1. activatePane(pane) - like Browser or Timeline
  2. activateTimeline
  2. activateBrowser

Move around in Timeline:

  2. timelineBeginning
  2. timelineEnd
  2. nextEdit
  2. previousEdit
  2. nextFrame
  2. previousFrame
  2. timelineMoveTo

Edit Timeline:

  2. selectClip - select the clip the scrub head is over
  2. addAllTransitions - selects everything and adds default transition.  This also selects titles
  2. addLowerThird - add lower third title.  It must be visible on the screen, or an error will occur.

Editing title

  2. openReplaceTitleText - open Replace Title Text Dialog
  2. replaceTitleText(old,new) - replace some text "all"

Rendering:

  2. renderProject(choice, suffix, tags) - render out video
  2. renderThumbnail(choice, suffix, tags) - render out video
  2. renderThumbs(limit, tags) - render out thumbnails
  2. renderVideo(limit, tags) - render out videos

Misc:

  1. newProject(name) - create a new project with name
  1. nextClip - advance to next clip
  1. traverseClips(callback,limit,delay) - apply callback to all (or limit) clips
  1. cutLastFootage
  1. pasteLastFootage

## Everything else

The rest of the file is of probably no interest to anyone (not that any of
this is).  I'm putting this out there so I don't forget, and perhaps someone else can use this info.  There is really a dearth of information right now and I couldn't find any extensive UI scripting examples.

