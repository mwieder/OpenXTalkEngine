script "revSaveAsEmscriptenStandalone"
/*
Copyright (C) 2015 LiveCode Ltd.

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

-- Support for creating HTML5 standalones using Emscripten

private command logDebug pStep, pMessage
   write "[" & pStep & "]" && pMessage & cr to stderr
end logDebug

----------------------------------------------------------------
-- Standalone generation
----------------------------------------------------------------

command revSaveAsEmscriptenStandalone pStack, pOutputFolder, pSettings
   
   logDebug "top", "----- Begin Emscripten standalone"
   
   -- FIXME
   dispatch "revIDEDeployEmscriptenInitialize" to stack "revDeployLibrary"
   
   local tArchs
   repeat for each item tItem in revSBPlatformArchitectures("Emscripten")
      if pSettings["Emscripten",tItem] then
         put true into tArchs[tItem]
      end if
   end repeat
   if the number of elements of tArchs is 0 then
      put true into tArchs["wasm"]
   end if
   combine tArchs by comma as set
   
   ---------- Pre-compute standalone build parameters
   
   -- Initial stack file
   local tStackFile
   put the effective filename of stack pStack into tStackFile
   
   -- Base directory
   local tBaseFolder
   set the itemDelimiter to slash
   put item 1 to -2 of tStackFile into tBaseFolder
   set the itemDelimiter to comma
   
   -- Other parameters
   local tName
   put pSettings["name"] into tName
   
   revStandaloneResetWarnings
   
   -- If we're searching for inclusions, do it here 
   if pSettings["inclusions"] is "search" then 
      revSBSearchForInclusions pStack, pSettings
   end if
   
   -- Make sure all dependencies are included
   revSBUpdateForDependencies "emscripten",,, pSettings
   
   /* Emscripten module resources are placed in `/boot/standalone` so we must
   * set the resources path appropriately. */
   put "/boot/standalone" into pSettings["resources_path"]
   revSBUpdateSettingsForExtensions "emscripten", pSettings
   
   local tResolvedFileData
   revSBResolveCopyFilesList tBaseFolder, "emscripten", pSettings, tResolvedFileData
   
   /* Process the resolved files, separating the custom standalone and fonts
   * files if available */
   local tCustomFiles
   local tFilesArray
   put "standalone.html" into tFilesArray[1]
   put "emscripten-web-fonts.txt" into tFilesArray[2]
   _processCustomFiles \
         tResolvedFileData, \
         tFilesArray, \
         tCustomFiles
   
   local tDeploy
   -- Update the deploy params with script library and extension inclusions
   revSBUpdateDeployParams pStack, "emscripten", pSettings, tDeploy
   
   local tError
   try
      ---------- Check deployment entitlement
      revStandaloneProgress "Checking deployment entitlement..."
      
      repeat for each item tArch in tArchs
         ---------- Create a working directory
         local tBuildFolder
         if the number of items in tArchs > 1 then
            put pOutputFolder & slash & tArch into tBuildFolder
         else
            put pOutputFolder into tBuildFolder
         end if
         
         if there is not a folder tBuildFolder then
            create folder tBuildFolder
            if the result is not empty then
               throw "could not create build folder for" && tArch && "target"
            end if
         end if
         
         logDebug "top", "Output folder: " && pOutputFolder
         
         ---------- Create new zip archive
         revStandaloneProgress "Creating standalone archive..."
         
         local tBuildZip
         put tBuildFolder & slash & "standalone.zip" into tBuildZip
         
         logDebug "top", "Archive:" && tBuildZip
         
         revZipOpenArchive tBuildZip, "write"
         
         if the result is not empty then
            throw "could not create standalone archive"
         end if
         
         -- Define some paths within the zip archive
         local tBootPath, tStandalonePath
         local tDeployedStackPath
         put "boot" into tBootPath
         put tBootPath & slash & "__startup.data" into tDeployedStackPath
         put tBootPath & slash & "standalone" into tStandalonePath
         
         -- Deploy the standalone application data
         storeDeployedStack tArch, tBuildZip, tDeployedStackPath, tBuildFolder, tStackFile, tDeploy
         
         -- Store extra, copied files
         storeAssets tBuildZip, tResolvedFileData, tStandalonePath, tBaseFolder
         
         -- Close zip file
         revZipCloseArchive tBuildZip
         if the result is not empty then
            throw "could not create standalone archive:" && the result
         end if
         
         ---------- Copy the engine into the build folder
         revStandaloneProgress "Preparing engine files..."
         local tEngineFiles
         put getEngineFiles(tArch) into tEngineFiles
         repeat for each key tEngineFile in tEngineFiles
            logDebug "engine", "Copying" && tEngineFiles[tEngineFile]
            revSBCopyFileToFileInFolder \
                  tEngineFiles[tEngineFile], \
                  tBuildFolder, \
                  tEngineFile, \
                  "revStandaloneProgressCallback", \
                  the long id of me
            
            if the result is not empty then
               throw "could not copy engine file" && tEngineFiles[tEngineFile] && the result
            end if
         end repeat
         
         ---------- Create HTML page
         
         -- FIXME just copies the Emscripten-generated page into place
         revStandaloneProgress "Preparing HTML page..."
         
         local tHtmlFile
         put tBuildFolder & slash & tName & ".html" into tHtmlFile
         logDebug "html", "Creating" && tHtmlFile
         
         local tHtmlTemplate
         put tCustomFiles["standalone.html"] into tHtmlTemplate
         if tHtmlTemplate is empty then
            put getHtmlTemplateFile(tArch) into tHtmlTemplate
            /* Load the contents of the default or custom webfonts file */
            local tWebFontsFile, tWebFontsText
            put tCustomFiles["web-fonts.txt"] into tWebFontsFile
            if tWebFontsFile is empty then
               put mapResPath(tArch, "emscripten-web-fonts.txt") into tWebFontsFile
            end if
            put url("binfile:" & tWebFontsFile) into tWebFontsText
            
            /* Read and merge the webfonts contents with the HTML template and
            * write it */
            local tHtmlTemplateText
            put url("binfile:" & tHtmlTemplate) into tHtmlTemplateText
            replace "${OXT_WEB_FONTS}" with tWebFontsText in tHtmlTemplateText
            put tHtmlTemplateText into url("binfile:" & tHtmlFile)
         else
            logDebug "html", "Copying" && tHtmlTemplate
            revSBCopyFileToFile mapBinPath(tArch, tHtmlTemplate), tHtmlFile, \
                  "revStandaloneProgressCallback", the long id of me
         end if
      end repeat
   catch tError
      if tError is empty then
         put "an unknown error occurred" into tError
      end if
      
      -- Cleanup on failure
      if there is a folder pOutputFolder then
         revDeleteFolder pOutputFolder
      end if
   end try
   
   local tOutcome
   if tError is not empty then
      put "FAILURE" into tOutcome
   else
      put "SUCCESS" into tOutcome
   end if
   
   logDebug "top", "----- (" & tOutcome & ") Emscripten Standalone"
   
   if tError is not empty then
      throw tError
   end if
   
end revSaveAsEmscriptenStandalone

----------------------------------------------------------------
-- Standalone deployment
----------------------------------------------------------------

private command storeDeployedStack pArch, pZip, pDeployPath, pBuildFolder, pMainStack, pDeployParams
   local tTempStackData, tTempStackPath, tStartupScript, tTempDeployPath
   
   ---------- Generate the startup script
   logDebug "startup", "Generating startup script"
   
   put getTemporaryBuildFile(pBuildFolder, ".livecode") into tTempStackPath
   put getPreparedStackAsData(pMainStack, pBuildFolder) into tTempStackData
   put tTempStackData into url ("binfile:" & tTempStackPath)
   
   put getStartupScript(pArch, pDeployParams["startup_script"]) into tStartupScript
   
   put pBuildFolder & slash & "emscriptendeploy.data" into tTempDeployPath
   
   put tStartupScript into pDeployParams["startup_script"]
   put tTempStackPath into pDeployParams["stackfile"]
   put tTempDeployPath into pDeployParams["output"]
   put empty into pDeployParams["engine"]
   
   // Externals are not yet supported in emscripten builds
   put empty into pDeployParams["externals"]
   
   ---------- Perform standalone deployment
   logDebug "deploy", "Deploying standalone"
   
    _internal deploy emscripten pDeployParams
#   if the result is not empty then
#      throw "could not deploy startup stack:" && the result
#   end if
   
   ---------- Store deployment data
   logDebug "deploy", "Storing" && tTempDeployPath
   local tDeployData
   
   -- We do this using data so that we can immediately delete the
   -- temporary file.  If used the file, we'd have to keep the
   -- file around until the zip file is finished.
   
logDebug "tTempDeployPath=", tTempDeployPath
   open file tTempDeployPath for binary read
   read from file tTempDeployPath until end
   put it into tDeployData
   close file tTempDeployPath
   
   revZipAddUncompressedItemWithData pZip, pDeployPath, "tDeployData"
   if the result is not empty then
      throw "could not store startup stack in standalone archive:" && the result
   end if
   
   ---------- Cleanup
   delete file tTempStackPath
   delete file tTempDeployPath # delete emscripten-deploy.data
   
end storeDeployedStack

-- Create the startup script by processing the startup stack template.
-- Engine-specific and standalone-specific data is substituted into the
-- template in order 
private function getStartupScript pArch, pGeneratedStartupScript
   local tTemplateFile, tScript
   
   -- Load template
   put getStartupTemplateFile(pArch) into tTemplateFile
   
   open file tTemplateFile for "UTF-8" text read
   if the result is not empty then
      throw tTemplateFile & ":" && the result
   end if
   read from file tTemplateFile until end
   put it into tScript
   if the result is not "eof" then
      throw tTemplateFile & ":" && the result
   end if
   close file tTemplateFile
   
   -- Make substitutions in the startup script
   replace "@ENGINE_VERSION@" with the version in tScript
   replace "@STARTUP_SCRIPT@" with pGeneratedStartupScript in tScript
   return tScript
end getStartupScript

----------------------------------------------------------------
-- Extra files from "copy files"
----------------------------------------------------------------

private command storeAssets pZip, pFileData, pStandalonePath, pBaseFolder
   -- Get a list of all the files to copy
   local tPath, tFiles, tCount
   
   -- Store all the files in the zip archive
   local tFolderFilesA,tFolderFilesCount
   put 0 into tFolderFilesCount
   repeat for each element tFileInfoElement in pFileData
      if there is a file tFileInfoElement["resolved"] then
         add 1 to tFolderFilesCount
         put tFileInfoElement["name"] into tFolderFilesA[tFolderFilesCount]["name"]
         put tFileInfoElement["name"] into tFolderFilesA[tFolderFilesCount]["dest"]
         put tFileInfoElement["resolved"] into tFolderFilesA[tFolderFilesCount]["resolved"]
      else if there is a folder tFileInfoElement["resolved"] then
         _storeAssetsR \
            tFileInfoElement["resolved"], \
            tFileInfoElement["name"], \
            tFolderFilesA, \
            tFolderFilesCount
      end if
   end repeat
   
   local tZipPath
   repeat for each element tFileInfo in tFolderFilesA
      logDebug "asset", "Storing" && tFileInfo["resolved"]
      
      put pStandalonePath & slash & tFileInfo["dest"] into tZipPath
      revZipAddItemWithFile pZip, tZipPath, tFileInfo["resolved"]
      if the result is not empty then
         throw "could not store asset file in standalone archive"
      end if
   end repeat
end storeAssets

private command _processCustomFiles @xResolvedFileData, pCustomFiles, @rCustomFiles
   repeat for each line tKey in the keys of xResolvedFileData
      repeat for each element tCustomFile in pCustomFiles
         if xResolvedFileData[tKey]["resolved"] ends with tCustomFile then
            put xResolvedFileData[tKey]["resolved"] into rCustomFiles[tCustomFile]
            delete variable xResolvedFileData[tKey]
         end if
      end repeat
   end repeat
end _processCustomFiles

----------------------------------------------------------------
-- Stack manipulation functions
----------------------------------------------------------------

-- Modifies a copy of <pStackFile> to prepare it for deployment,
-- and then returns the modified stack file's contents as data. 
-- <pStackFile> is not modified.
private function getPreparedStackAsData pStackFile, pBuildFolder
   local tStack, tDefaultStack, tError, tResult
   local tTempFile, tCleanTempFile
   local tStandaloneSettings
   local tStackData
   
   put the long id of stack pStackFile into tStack
   local tName
   put the short name of stack pStackFile into tName
   try
      if revIDEStackNameIsIDEStack(the name of tStack) then
         -- Don't manipulate IDE stacks if for some reason someone
         -- tries to put one into a standalone
         put the filename of tStack into tTempFile
         put false into tCleanTempFile
         
      else
         
         -- Get a temporary filename
         put getTemporaryBuildFile(pBuildFolder, ".livecode") into tTempFile
         put true into tCleanTempFile
         
         /* Retain the standalone settings without the deployment password
         * as some widgets, such as map, store the api key here which is
         * needed at runtime. */
         put the customProperties["cRevStandaloneSettings"] of tStack into tStandaloneSettings
         delete variable tStandaloneSettings["password"]
         set the customProperties["cRevStandaloneSettings"] of tStack to tStandaloneSettings      
         
         -- Save the modified stack to the temporary file
         lock screen
         
         save tStack as tTempFile with newest format
         put the result into tResult
         if tResult is not empty then
            throw tTempFile & ":" && tResult
         end if
         
         set the filename of stack tName to pStackFile
         
         -- Revert to unmodified state
         
         revert stack tName
         set the defaultStack to tName
         
         unlock screen
         
      end if
      
      open file tTempFile for binary read
      if the result is not empty then
         throw tTempFile & ":" && the result
      end if
      read from file tTempFile until end
      put it into tStackData
      if the result is not "eof" then
         throw tTempFile & ":" && the result
      end if
      close file tTempFile
      
   catch tError
   end try
   
   if tCleanTempFile and there is a file tTempFile then
      delete file tTempFile
   end if
   
   if tError is not empty then
      throw tError
   end if
   
   return tStackData
end getPreparedStackAsData

----------------------------------------------------------------
-- File & path helper functions
----------------------------------------------------------------

-- Map a compiled file's path into an absolute filesystem path.  This
-- is used to cope with running from a git repository working tree.
private function mapBinPath pArch, pPath
   if there is a file pPath then
      return pPath
   end if
   
   if revEnvironmentIsInstalled() then
      -- We're running from an installed version of LiveCode
      return getRuntimeFolder(pArch) & slash & pPath
   else
      -- We're running from a git checkout
      return getRepoBinariesFolder(pArch) & slash & pPath
   end if
end mapBinPath

-- Map a resource file's path into an absolute filesystem path.  This
-- is used to cope with running from a git repository working tree.
private function mapResPath pArch, pPath
   if there is a file pPath then
      return pPath
   end if

   if revEnvironmentIsInstalled() then
      return getRuntimeFolder(pArch) & slash & pPath
   else
      return getRepoBinariesFolder(pArch) & slash & pPath
   end if
end mapResPath

-- Scan a directory, returning a number-indexed array of files found.
-- The returned paths are relative to the specified directory.
private function scanFolder pFolder
   local tTemplateRoot, tFiles, tCount, tError
   
   -- Short-circuit if pFolder is missing
   if there is no folder pFolder then
      return empty
   end if
   
   put 0 into tCount
   put empty into tFiles
   
   revIDEPushDefaultFolder pFolder
   try
      scanFolder_recurse tCount, tFiles, empty
   catch tError
   end try
   
   revIDEPopDefaultFolder
   
   if tError is not empty then
      throw tError
   end if
   
   return tFiles
end scanFolder

-- Recursive function used by scanFolder()
private command scanFolder_recurse @xCount, @xFiles, pRelPath
   local tFile, tFilepath, tSaveFolder

   -- List files
   repeat for each line tFile in the files
      -- Skip dotfiles
      if tFile begins with "." then
         next repeat
      end if

      add 1 to xCount
      put tFile into tFilePath
      if pRelPath is not empty then
         put pRelPath & slash before tFilePath
      end if
      put tFilePath into xFiles[xCount]
   end repeat

   -- Recurse
   put the defaultfolder into tSaveFolder
   repeat for each line tFolder in the folders
      if tFolder begins with "." then
         next repeat
      end if

      set the defaultfolder to tSaveFolder & slash & tFolder
      if pRelPath is not empty then
         put pRelPath & slash before tFolder
      end if
      scanFolder_recurse xCount, xFiles, tFolder
   end repeat

   set the defaultFolder to tSaveFolder
end scanFolder_recurse

function revGetEmscriptenFiles pArch
   return getEngineFiles(pArch)
end revGetEmscriptenFiles

-- Return a number-indexed array of engine files that need to be
-- copied into the standalone output folder.
private function getEngineFiles pArch
   local tFiles
   
   switch pArch
      case "js"
         -- Engine JavaScript
         put mapBinPath("js", "standalone-" & the version & ".js") \
            into tFiles["standalone-" & the version & ".js"]
         -- Memory initialisation file
         put mapBinPath("js", "standalone-" & the version & ".html.mem") \
            into tFiles["standalone-" & the version & ".html.mem"]
         break
      case "wasm"
      default
         -- Engine JavaScript
         put mapBinPath("wasm", "standalone.js") \
            into tFiles["standalone.js"]
         -- Engine WebAssembly binary
         put mapBinPath("wasm", "standalone.wasm") \
            into tFiles["standalone.wasm"]
         break
   end switch

   -- ICU data
#   put mapCommonPath("icu-core.dat") into tFiles["icu-core.dat"]
 #  put mapCommonPath("icu-iter.dat") into tFiles["icu-iter.dat"]
  # put mapCommonPath("icu-coll.dat") into tFiles["icu-coll.dat"]

   put fakeMapCommonPath("icu-core.dat") into tFiles["icu-core.dat"]
   put fakeMapCommonPath("icu-iter.dat") into tFiles["icu-iter.dat"]
   put fakeMapCommonPath("icu-coll.dat") into tFiles["icu-coll.dat"]
   
   return tFiles
end getEngineFiles

function fakeMapCommonPath pDatFile
	return "~/livecode/linux-x86_64-bin/Runtime/Common/" & pDatFile
end fakeMapCommonPath

-- Get the filename of the Emscripten standalone template folder.
-- This is a folder that contains the default filesystem
-- initialisation data that's automatically included in all
-- standalones (especially fonts).
--private function getStandaloneTemplateFolder
   --return mapResPath("emscripten-standalone-template")
--end getStandaloneTemplateFolder

-- Return a number-indexed array of files in the Emscripten standalone
-- template folder.  The paths returned are relative to the path returned
-- by getStandaloneTemplateFolder()
--private function getStandaloneTemplateFiles
   --return scanFolder(getStandaloneTemplateFolder())
--end getStandaloneTemplateFiles

-- Get the filename of the Emscripten standalone template HTML file.
-- This has some standalone-dependent JavaScript substituted into it
-- to instantiate the engine.
private function getHtmlTemplateFile pArch
   --return mapBinPath("standalone-" & getEngineType() & "-" & the version & ".html")
   return mapBinPath(pArch, "standalone.html")
end getHtmlTemplateFile

-- Get the filename of the Emscripten standalone startup script-only
-- stack template.
private function getStartupTemplateFile pArch
   return mapResPath(pArch, "emscripten-startup-template.livecodescript")
end getStartupTemplateFile

-- Get the directory containing the Emscripten runtime
private function getRuntimeFolder pArch
   
   local tRelFolder, tOverridePath, tUserPath
   
   put slash & "Emscripten" & slash & pArch into tRelFolder
   
   put revOverrideRuntimePath() into tOverridePath
   if tOverridePath is not empty then
      put tRelFolder after tOverridePath
      if there is a folder tOverridePath then
         return tOverridePath
      end if
   end if
   
   put revEnvironmentUserRuntimePath() into tUserPath
   if tUserPath is not empty then
      put tRelFolder after tUserPath
      if there is a folder tUserPath then
         return tUserPath
      end if
   end if
   
   return revEnvironmentRuntimePath() & tRelFolder
end getRuntimeFolder

-- Get the directory where Emscripten binaries end up (specifically,
-- the engine's JavaScript file).
-- Get the directory where Emscripten development binaries and resources are installed to.
private function getRepoBinariesFolder pArch
   return "~/livecode/linux-x86_64-bin/Runtime/Emscripten/" & pArch
   --return revEnvironmentRepositoryPath() & slash & "emscripten-" & pArch & "-bin"
end getRepoBinariesFolder

-- Get the directory where Emscripten resources are kept
--private function getRepoResourceFolder
--return revEnvironmentRepositoryPath() & slash & "engine" & slash & "rsrc"
--end getRepoResourceFolder

-- Get a temporary filename in <pBuildFolder> with the extension
-- <pExtension>
private function getTemporaryBuildFile pBuildFolder pExtension
   local tFile
   repeat forever
      put pBuildFolder & slash & (the random of 1000000) & pExtension into tFile
      if there is not a file tFile then
         exit repeat
      end if
   end repeat
   return tFile
end getTemporaryBuildFile

----------------------------------------------------------------
-- Other utility functions
----------------------------------------------------------------

-- Check if the license permits HTML5 deployment
private function isPermittedDeployment
   --if isCommercialDeployment() then
      --return ("HTML5" is among the items of line 5 of the revLicenseInfo)
   --else
      return true
   --end if
end isPermittedDeployment


private function isCommercialDeployment
   --if revLicenseType() is "community" then
      --return false
   --else
      return true
   --end if
end isCommercialDeployment

end isCommercialDeployment

end isCommercialDeployment

end isCommercialDeployment

end isCommercialDeployment

end isCommercialDeployment

-- Get the engine type string ("commercial" or "community")
private function getEngineType
   if isCommercialDeployment() then
      return "commercial"
   else
      return "community"
   end if
end getEngineType
