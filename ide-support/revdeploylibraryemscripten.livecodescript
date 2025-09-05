script "revdeploylibraryemscripten"
/* Copyright (C) 2017 LiveCode Ltd.

This file is part of LiveCode.

LiveCode is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

LiveCode is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with LiveCode.  If not see <http://www.gnu.org/licenses/>.  */

constant kLinuxBrowserList = "Firefox=firefox/firefox,Chrome=google-chrome/google-chrome,Brave=brave/brave"
constant kPrivateModeSuffix = "[Private Mode]"
# TODO: update this
constant kBuildSpace = "livecode-emscripten-builds"
--constant kBuildSpace = "oxt-emscripten-builds"

local sBrowsers
local sServerPort
local sHTTPFileSpace

command deployInitialize
   local tBrowserList
   put __deployGetBrowserList() into tBrowserList
   split tBrowserList by cr and comma
   put tBrowserList into sBrowsers

   repeat for each key tBrowser in tBrowserList
      if __deployBrowserSupportsPrivateMode?(tBrowser) then
         put tBrowserList[tBrowser] into sBrowsers[tBrowser && kPrivateModeSuffix]
      end if
   end repeat

# do this for html5 build
   put the temporary folder & slash & kBuildSpace into sHTTPFileSpace
   if not (there is a folder sHTTPFileSpace) then
      create folder sHTTPFileSpace
   end if
   revIDEDeployTargetsChanged
end deployInitialize

--function deployIsAvailable?
--	# never empty, so
--   return true
--end deployIsAvailable?

function deployListTargets
   local tTargets
   put the keys of sBrowsers into tTargets
   filter tTargets without empty
   sort tTargets

   if tTargets is not empty then
      put cr before tTargets
   end if
   put "Default Browser" before tTargets
   return tTargets
end deployListTargets

/*
*  Create a local HTTP server using the HTTPd library,
*  build the HTML 5 standalone then launch the local URL
*  for the standalone in the chosen browser.
*/
command deployDo pTargetStack, pBrowser
   local tError
   put empty into tError

   if tError is empty then
      revStandaloneProgress "Configuring HTTP server..."

      if sServerPort is not empty and sServerPort is not among the lines of the openSockets then
         httpdStop sServerPort
         put empty into sServerPort
      end if

      if sServerPort is empty then
         httpdStart "deployEmscriptenNewHTTPRequest", 0
         if the result is not empty or it is not an integer then
            put "Could not start HTTP server" && the result && it into tError
         else
            put it into sServerPort
         end if
      end if
   end if

   /* Ensure the temporary folder used to build emscripten standalones for testing exists. */
   if tError is empty and sHTTPFileSpace is empty then
      put the temporary folder & slash & "livecode-emscripten-builds" into sHTTPFileSpace
      if there is not a folder sHTTPFileSpace then
         create folder sHTTPFileSpace
         if the result is not empty then
            put "Could not create temporary build folder:" && the result into tError
         end if
      end if
   end if

   local tBuildFolder, tStandalonePath
   if tError is empty then
      revStandaloneProgress "Building standalone..."

      local tSettings
      put SBGetSettings(pTargetStack, true) into tSettings

      put sHTTPFileSpace & slash & tSettings["name"] into tBuildFolder
      if there is a folder tBuildFolder then
         revDeleteFolder tBuildFolder
      end if
      create folder tBuildFolder

      put urlencode(tSettings["name"]) & slash & urlencode(tSettings["name"]) & ".html" into tStandalonePath

      try
         if tSettings["EmscriptenWASM"] is true then
            dispatch "saveAsEmscriptenWASMStandalone" to stack "revsaveasEmscriptenStandalone" with \
                  pTargetStack, tBuildFolder, tSettings
         else if tSettings["EmscriptenJS"] is true then
            dispatch "saveAsEmscriptenHTML5Standalone" to stack "revsaveasEmscriptenStandalone" with \
                  pTargetStack, tBuildFolder, tSettings
         end if
      catch tException
         put "Unable to build app for testing:" && tException into tError
      end try
   end if

   if tError is empty then
      revStandaloneProgress "Launching URL..."

      local tPrivateMode
      put pBrowser ends with kPrivateModeSuffix into tPrivateMode

      --__deployLaunchURLInBrowser "http://localhost:" & sServerPort & slash & tStandalonePath, sBrowsers[pBrowser], tPrivateMode
      __deployLaunchURLInBrowser "http://localhost:" & sServerPort & slash & tStandalonePath, word 1 of pBrowser, tPrivateMode
      if the result is not empty then
         put "Could not open URL" && the result into tError
      end if
   end if

   if tError is not empty and there is a folder tBuildFolder then
      revDeleteFolder tBuildFolder
   end if

   if "revStandaloneProgress" is among the lines of the openStacks then
      close stack "revStandaloneProgress"
   end if

   return tError
end deployDo

////////////////////////////////////////////////////////////////////////////////

-- Returns a return delimited list of the form <browser>,<path to exe>
-- Use an internal command on OSX, the registry in Windows and a static list on Linux.
-- Not implemented on other platforms - we just use the default browser here.
--
private function __deployGetBrowserList
   local tBrowserList

   switch the platform
      case "MacOS"
         _internal list browsers
         put the result into tBrowserList
         break

      case "Win32"
         -- According to https://msdn.microsoft.com/en-us/library/dd203067(VS.85).aspx
         -- browsers should register in the registry at HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet
         local tBrowsers
         put listRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet") into tBrowsers
         repeat for each line tBrowser in tBrowsers
            if tBrowserList is not empty then
               put cr after tBrowserList
            end if
            put queryRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\" & tBrowser & backslash) & comma & \
                  queryRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\" & tBrowser & "\shell\open\command\") after tBrowserList
         end repeat
         replace quote with empty in tBrowserList
         break

      case "Linux"
         -- For linux, we have a list of known browsers.
         -- Check to see if the exe is in the path or installed in the user's home dir.

         local tBrowserArray
         put kLinuxBrowserList into tBrowserArray
         split tBrowserArray by comma and "="

         set the itemDel to slash
         repeat for each key tBrowser in tBrowserArray
            get shell("which" && item 1 of tBrowserArray[tBrowser])
            if it is not empty then
               put it into tBrowserList[tBrowser]
            else
               local tUserBrowserPath
               put $HOME & slash & tBrowserArray[tBrowser] into tUserBrowserPath
               if there is a file tUserBrowserPath then
                  put tUserBrowserPath into tBrowserList[tBrowser]
               end if
            end if
         end repeat
         set the itemDel to comma

         combine tBrowserList with cr and comma
         break

      default
         put empty into tBrowserList
         break
   end switch
   return tBrowserList
end __deployGetBrowserList

-- Add any exta command line args that we might want to pass to the browser.
-- e.g. javascript consoles, debug modes etc
--
-- Chrome - https://src.chromium.org/viewvc/chrome/trunk/src/chrome/common/chrome_switches.cc
-- Firefox - https://developer.mozilla.org/en-US/docs/Mozilla/Command_Line_Options
-- Opera - http://www.opera.com/docs/switches/
-- Safari doesn't support command line flags. We could potentially use applescript on OS X, though it's somewhat hacky.
--
private function __deployGetBrowserArgs pBrowser
   return empty
end __deployGetBrowserArgs pBrowser

private function __deployBrowserSupportsPrivateMode? pBrowser
   return __deployGetBrowserPrivateModeArgs(pBrowser) is not empty
end __deployBrowserSupportsPrivateMode?

private function __deployGetBrowserPrivateModeArgs pBrowser
   local tPrivateMode
   switch
      case pBrowser contains "brave"
      case pBrowser contains "chrome"
         put "--incognito" into tPrivateMode
         break
      case pBrowser contains "iexplore"
         put "-private" into tPrivateMode
         break
      case pBrowser contains "firefox"
         -- We use the open command on OS X to launch browsers.
         -- This takes care of managing multiple instances - if already running, the exisiting instance will be brought to the foreground with the given URL.
         -- However, this means that if the browser is already open, command line args are lost.
         -- So when we want to pass args, we force start a new instance - most browsers handle this appropriately.
         -- However, firefox complains and exits (when running multiple instances on OS X), which means we can't fully support private mode using this method.
         -- It will only work if firefox is not already running (or we could try a nasty apple script hack but that susceptible to menu/shortcut changes).
         if the platform is "MacOS" then
            --return empty
         else
            put "-private-window" into tPrivateMode
         end if
         break
      case pBrowser contains "opera"
         put "-newprivatetab" into tPrivateMode
         break
         --default
         --return empty
   end switch
   return tPrivateMode
end __deployGetBrowserPrivateModeArgs

private command __deployLaunchURLInBrowser pURL, pBrowser, pPrivateMode?
   if pBrowser is empty or pBrowser is "default" then
      # use the default browser
      launch URL pURL
      return the result
   else
      replace "chrome" with "google-chrome" in pBrowser
      local tArgs
      put __deployGetBrowserArgs(pBrowser) into tArgs
      if pPrivateMode? then
         if tArgs is not empty then
            put space after tArgs
         end if
         put __deployGetBrowserPrivateModeArgs(pBrowser) after tArgs
      end if

      switch the platform
         case "MacOS"
            if tArgs is not empty then
               -- If we want to pass any command line args to the browser, we need to force start a new instance using -n
               -- Most browsers appear to handle relaunches in a graceful way.
               put "-n --args " before tArgs
            end if
            return shell("open -a" && q(pBrowser) && tArgs && q(pURL))

         case "Win32"
            local tHideConsoleWindows
            put the hideConsoleWindows into tHideConsoleWindows
            set the hideConsoleWindows to true
            get shell(q(pBrowser) && tArgs && q(pURL))
            set the hideConsoleWindows to tHideConsoleWindows
            return it

         case "Linux"
            local tShell
            -- this will take care of firefox and google-chrome
            put lower(pBrowser) into tShell
            local tCommand
            if "chrome" is in pBrowser then
               put " --new-window --cors-exempt-headers" after tArgs
            end if
            put q(tShell) && tArgs && q(pURL) into tCommand
            return shell(tCommand)
         default
            launch URL pURL
            return the result
      end switch
   end if
end __deployLaunchURLInBrowser

/**
* Callback from the HTTP daemon.
* In this case we just want to serve the requested file
* if it exists in the temp file space.
* POST requests to stdio.html are log messages from emscripten.
* Display these in the message box.
*/
on deployEmscriptenNewHTTPRequest pSocketID, pRequest
   local tPath
   set the itemDel to slash
   repeat for each item tSubPath in pRequest["resource"]
      if tPath is not empty then
         put slash after tPath
      end if
      put urlDecode(tSubPath) after tPath
   end repeat
   set the itemDel to comma
   put sHTTPFileSpace & slash before tPath

   local tMimeType
   if tPath ends with ".html" then
      put "text/html" into tMimeType
   else if tPath ends with ".html.mem" then
      put "application/octet-stream" into tMimeType
   else if tPath ends with ".js" then
      put "text/javascript" into tMimeType
   else if tPath ends with ".wasm" then
      put "application/wasm" into tMimeType
   end if

   local tResponseHeaders
   if tMimeType is not empty then
      put "Content-Type:" && tMimeType & cr after tResponseHeaders
   end if

   if there is a file tPath then
      httpdResponse pSocketID, 200, URL ("binfile:" & tPath), tResponseHeaders
   else
      set the itemDel to slash
      if the last item pRequest["resource"] is "stdio.html" and pRequest["method"] is "POST" then
         local tContent
         put urlDecode(pRequest["content"]) into tContent

         -- Parse and display emscripten log messages in the message box.
         -- Log messages from emscripten appear to be of the form
         -- ^<err|out|pageload|exit>^[count^]<message>
         -- Output a message header then the message body itself
         local tMsgType, tMsgTypeCount, tMsgBody
         put item 2 to -2 of pRequest["resource"] after msg
         if matchText(tContent, "^\^(.+)\^([0-9]+)\^(.*)$", tMsgType, tMsgTypeCount, tMsgBody) then
            put " -" && tMsgType && "#" & tMsgTypeCount & cr after msg
            if tMsgBody is not empty then
               put tMsgBody & cr after msg
            end if
         else if matchText(tContent, "^\^(.+)\^(.*)$", tMsgType, tMsgBody) then
            put " -" && tMsgType & cr after msg
            if tMsgBody is not empty then
               put tMsgBody & cr after msg
            end if
         else
            put tContent & cr after msg
         end if

         httpdResponse pSocketID, 200
      else
         httpdResponse pSocketID, 404
      end if
      --set the itemDel to comma
   end if
end deployEmscriptenNewHTTPRequest
