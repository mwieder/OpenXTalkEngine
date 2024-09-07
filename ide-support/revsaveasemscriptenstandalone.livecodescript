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

-- Support for creating HTML5 and WASM standalones using Emscripten

/*
* logDebug
*/
private command logDebug pStep, pMessage
   write "[" & pStep & "]" && pMessage & cr to stderr
end logDebug

/*
* createZipFileIfNecessary
*/
private command createZipFileIfNecessary pArchive
   if there is a file pArchive then
      revZipOpenArchive pArchive, "update"
   else
      revZipOpenArchive pArchive, "write"
   end if
   if the result is not empty then
      throw "could not create standalone archive" && pArchive
   end if
end createZipFileIfNecessary

----------------------------------------------------------------
-- Standalone generation
----------------------------------------------------------------

/*
* See which emscripten architectures we want to build
*/
private function architectureListFromSettingsArray pSettingsArray
   local tArchs
   repeat for each item tItem in revSBPlatformArchitectures("Emscripten")
      if pSettingsArray["Emscripten",tItem] then
         put true into tArchs[tItem]
      end if
   end repeat
   # default to wasm build
   if the number of elements of tArchs is 0 then
      put true into tArchs["wasm"]
   end if
   combine tArchs by comma as set # just the keys
   return tArchs
end architectureListFromSettingsArray

private function baseDirectoryFromStackFile pStackFolder
   local tBaseFolder
   set the itemDelimiter to slash
   put item 1 to -2 of pStackFolder into tBaseFolder
   return tBaseFolder
end baseDirectoryFromStackFile

private function createZipArchiveFromFolder pBuildFolder
   local tBuildZipArchive
   put pBuildFolder & slash & "standalone.zip" into tBuildZipArchive
   
   logDebug "top", "Archive:" && tBuildZipArchive
   
   createZipFileIfNecessary tBuildZipArchive
   return tBuildZipArchive
end createZipArchiveFromFolder

/*
* saveAsEmscriptenHTML5Standalone
*  pSettings : array of assets to encapsulate
*/
command saveAsEmscriptenHTML5Standalone pStack, pOutputFolder, pSettings
   logDebug "top", "----- Begin Emscripten HTML5 standalone"
   
   ---------- Pre-compute standalone build parametersArch
   
   local tArchs
   put architectureListFromSettingsArray(pSettings) into tArchs
   logDebug "tArchs", tArchs
   
   -- Initial stack file
   local tStackFile
   put the effective filename of stack pStack into tStackFile
   
   -- Base directory
   local tBaseFolder
   put baseDirectoryFromStackFile(tStackFile) into tBaseFolder
   
   -- Other parameters
   local tName
   put pSettings["name"] into tName
   
   revStandaloneResetWarnings
   
   # If we're searching for inclusions, do it here 
   if pSettings["inclusions"] is "search" then 
      revSBSearchForInclusions pStack, pSettings
   end if
   
   # Make sure all dependencies are included
   revSBUpdateForDependencies "emscripten",,, pSettings
   
   revSBUpdateSettingsForExtensions "emscripten", pSettings
   
   local tResolvedFileData
   revSBResolveCopyFilesList tBaseFolder, "emscripten", pSettings, tResolvedFileData
   
   local tDeploy
   -- Update the deploy params with script library and extension inclusions
   revSBUpdateDeployParams pStack, "emscripten", pSettings, tDeploy
   
   local tError
   try
      ---------- Create a working directory
      local tBuildFolder
      
      # TODO : Is this necessary?
      replace space with "_" in pOutputFolder
      put pOutputFolder into tBuildFolder
      create folder tBuildFolder # if it doesn't already exist
      
      logDebug "top", "Output folder: " && pOutputFolder
      
      ---------- Create new zip archive
      revStandaloneProgress "Creating standalone archive..."
      
      local tBuildZip # destination path for the zip file
      put createZipArchiveFromFolder(tBuildFolder) into tBuildZip
      
      -- Store template files
      local tZipTemplateFile, tZipTemplateFolder, tZipTemplatePath
      put HTML5.standaloneTemplateFolder("js") into tZipTemplateFolder
      
      logDebug "top", "zipTemplateFolder:" && tZipTemplateFolder
      
      repeat for each element tZipTemplateFile in HTML5.StandaloneTemplateFiles()
         put tZipTemplateFolder & slash & tZipTemplateFile into tZipTemplatePath
         logDebug "template", "Storing" && tZipTemplatePath
         revZipAddUncompressedItemWithFile tBuildZip, tZipTemplateFile, tZipTemplatePath
         if the result is not empty then
            throw "could not store template files in standalone archive"
         end if
      end repeat
      
      # Define some paths within the zip archive
      local tBootPath, tStandalonePath
      local tDeployedStackPath
      put "boot" into tBootPath
      put tBootPath & slash & "__startup.data" into tDeployedStackPath
      put tBootPath & slash & "standalone" into tStandalonePath
      
      # Deploy the standalone application data into /boot/__startup.data
      storeDeployedStack "js", tBuildZip, tDeployedStackPath, tBuildFolder, tStackFile, tDeploy
      
      # Store extra, copied files into /boot/standalone
      storeAssets tBuildZip, tResolvedFileData, tStandalonePath, tBaseFolder
      
      # Close zip file
      revZipCloseArchive tBuildZip
      if the result is not empty then
         throw "could not create standalone archive:" && the result
      end if
      
      if there is no file tBuildZip then
         throw "could not create standalone archive: no zip file"
      end if
      
      ---------- Copy the engine into the build folder
      revStandaloneProgress "Preparing engine files..."
      local tEngineFile
      local tEngineFiles
      --      repeat for each element tEngineFile in getEngineFiles("js")
      --         logDebug "engine", "Copying" && tEngineFile
      --         revSBCopyFileToFolder tEngineFile, tBuildFolder, "revStandaloneProgressCallback", the long id of me
      
      --         if the result is not empty then
      --            throw "could not copy engine file" && the result
      --         end if
      --      end repeat
      
      put getEngineFiles("js") into tEngineFiles
      repeat for each key tEngineFile in tEngineFiles
         logDebug "engine", "Copying" && tEngineFiles[tEngineFile]
         revSBCopyFileToFileInFolder tEngineFiles[tEngineFile], tBuildFolder, tEngineFile, "revStandaloneProgressCallback", the long id of me
         
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
      logDebug "html", "Copying" && getHtmlTemplateFile("js")
      revSBCopyFileToFile mapBinPath("js", getHtmlTemplateFile("js")), tHtmlFile, \
            "revStandaloneProgressCallback", the long id of me
      
   catch tError
      put cleanupOnFailure(tError, pOutputFolder) into tError
   end try
   
   local tOutcome
   if tError is not empty then
      put "FAILURE" into tOutcome
   else
      put "SUCCESS" into tOutcome
   end if
   
   logDebug "top", "----- (" & tOutcome & ") Emscripten HTML5 Standalone"
   
   if tError is not empty then
      throw tError
   end if
end saveAsEmscriptenHTML5Standalone

/*
* saveAsEmscriptenWASMStandalone
*  pSettings : array of assets to encapsulate
*/
command saveAsEmscriptenWASMStandalone pStack, pOutputFolder, pSettings
   
   logDebug "top", "----- Begin Emscripten WASM standalone"
   
   -- FIXME
   dispatch "revIDEDeployEmscriptenInitialize" to stack "revDeployLibrary"
   
   local tArchs
   put architectureListFromSettingsArray(pSettings) into tArchs
   
   ---------- Pre-compute standalone build parameters
   
   # Initial stack file
   local tStackFile
   put the effective filename of stack pStack into tStackFile
   
   # Base directory
   local tBaseFolder
   put baseDirectoryFromStackFile(tStackFile) into tBaseFolder
   
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
   
   /* Emscripten wasm module resources are placed in `/boot/standalone` so we must
   * set the resources path appropriately. */
   put "/boot/standalone" into pSettings["resources_path"]
   revSBUpdateSettingsForExtensions "emscripten", pSettings
#         storeAssets tBuildZip, tResolvedFileData, tStandalonePath, tBaseFolder

   local tResolvedFileData
   revSBResolveCopyFilesList tBaseFolder, "emscripten", pSettings, tResolvedFileData
   
   logDebug "tArch[wasm]", tArchs
   	   
   # Process the resolved files, separating the custom standalone and fonts files if available
   local tCustomFiles
   local tFilesArray
   put "standalone.html" into tFilesArray[1]
   put "emscripten-web-fonts.txt" into tFilesArray[2]
   WASM.ProcessCustomFiles tResolvedFileData, tFilesArray, tCustomFiles
   
   local tDeploy
   # Update the deploy params with script library and extension inclusions
   revSBUpdateDeployParams pStack, "emscripten", pSettings, tDeploy
   
   local tError
   try
      repeat for each item tArch in tArchs
         logDebug "loop", "tArch: " && tArch
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
         --         put tBuildFolder & slash & "standalone.zip" into tBuildZip
         
         --         logDebug "top", "Archive:" && tBuildZip
         
         --         createZipFileIfNecessary tBuildZip
         
         put createZipArchiveFromFolder(tBuildFolder) into tBuildZip
         --         if the result is not empty then
         --            throw "could not create standalone archive"
         --         end if
         
         -- Define some paths within the zip archive
         local tBootPath, tStandalonePath
         local tDeployedStackPath
         put "boot" into tBootPath
         put tBootPath & slash & "__startup.data" into tDeployedStackPath
         put tBootPath & slash & "standalone" into tStandalonePath
         
         -- Deploy the standalone application data
         
         logDebug "stack", tStackFile
         
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
            revSBCopyFileToFileInFolder tEngineFiles[tEngineFile], tBuildFolder, tEngineFile, "revStandaloneProgressCallback", the long id of me
            
            if the result is not empty then
               throw "could not copy engine file" && tEngineFiles[tEngineFile] && the result
            end if
         end repeat
         
         ---------- Create HTML page
         
         revStandaloneProgress "Preparing HTML page..."
         
         local tHtmlFile
         put tBuildFolder & slash & tName & ".html" into tHtmlFile
         logDebug "html", "Creating" && tHtmlFile
         
         local tHtmlTemplate
         put tCustomFiles["standalone.html"] into tHtmlTemplate
         if tHtmlTemplate is empty then
            put getHtmlTemplateFile(tArch) into tHtmlTemplate
            /* Load the contents of the default or custom webfonts file */
            local tWebFontsFile
            put tCustomFiles["web-fonts.txt"] into tWebFontsFile
            if tWebFontsFile is empty then
               put mapBinPath(tArch, "emscripten-web-fonts.txt") into tWebFontsFile
            end if
            local tWebFontsText
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
      put cleanupOnFailure(tError, pOutputFolder) into tError
   end try
   
   local tOutcome
   if tError is not empty then
      put "FAILURE" into tOutcome
   else
      put "SUCCESS" into tOutcome
   end if
   
   logDebug "top", "----- (" & tOutcome & ") Emscripten WASM Standalone"
   
   if tError is not empty then
      throw tError
   end if
end saveAsEmscriptenWASMStandalone

private function cleanupOnFailure pError, pOutputFolder
   if pError is empty then
      put "an unknown error occurred" into pError
   end if
   
   -- Cleanup on failure
   if there is a folder pOutputFolder then
      revDeleteFolder pOutputFolder
   end if
   return pError
end cleanupOnFailure

----------------------------------------------------------------
-- Standalone deployment
----------------------------------------------------------------

/*
* storeDeployedStack
*/
private command storeDeployedStack pArch, pZip, pDeployPath, pBuildFolder, pMainStack, pDeployParams
   local tTempStackData, tTempStackPath, tTempDeployPath
   
   ---------- Generate the startup script
   logDebug "startup", "Generating startup script"
   --   logDebug "startup", "pArch" && pArch
   --   logDebug "startup", "pZip" && pZip
   --   logDebug "startup", "pDeployPath" && pDeployPath
   --   logDebug "startup", "pBuildFolder" && pBuildFolder
   --   logDebug "startup", "pMainStack" && pMainStack
   
   put getTemporaryBuildFile(pBuildFolder, ".livecode") into tTempStackPath
   logDebug "startup", "saving to" && tTempStackPath
   put getPreparedStackAsData(pMainStack, pBuildFolder) into tTempStackData
   
   put tTempStackData into url ("binfile:" & tTempStackPath)
   
   put getStartupScript(pArch, pDeployParams["startup_script"]) into pDeployParams["startup_script"]
   put tTempStackPath into pDeployParams["stackfile"]
   put pBuildFolder & slash & "emscriptendeploy.data" into tTempDeployPath
   put tTempDeployPath into pDeployParams["output"]
   put empty into pDeployParams["engine"]
   
   // Externals are not yet supported in emscripten builds
   put empty into pDeployParams["externals"]
   
   ---------- Perform standalone deployment
   logDebug "deploy", "Deploying standalone"
   
   _internal deploy emscripten pDeployParams
   if the result is not empty then
      throw "could not deploy startup stack:" && the result
   end if
   
   ---------- Store deployment data
   logDebug "deploy", "Storing" && tTempDeployPath
   local tDeployData
   
   -- We do this using data so that we can immediately delete the
   -- temporary file.  If used the file, we'd have to keep the
   -- file around until the zip file is finished.
   
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

/*
* Create the startup script by processing the startup stack template.
* Engine-specific and standalone-specific data is substituted into the template in order
* The template file is identical for js and wasm builds
*/
private function getStartupScript pArch, pGeneratedStartupScript
   local tTemplateFile, tScript
   
   -- Load emscripten-startup-template.livecodescript
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

/*
*
*/
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

/*
*
*/
private command _storeAssetsR pFolder, pName, @xFilesA, @xCount
   
   local tFolderFiles
   put files(pFolder) into tFolderFiles
   repeat for each line tLine in tFolderFiles
      add 1 to xCount
      put tLine into xFilesA[xCount]["name"]
      put pName & slash & tLine into xFilesA[xCount]["dest"]
      put pFolder & slash & tLine into xFilesA[xCount]["resolved"]
   end repeat
   
   local tSubFolders
   put folders(pFolder) into tSubFolders
   repeat for each line tLine in tSubFolders
      if tLine begins with "." then
         next repeat
      end if
      _storeAssetsR \
            pFolder & slash & tLine, \
            pName & slash & tLine, \
            xFilesA, \
            xCount
   end repeat
end _storeAssetsR

/*
* WASMProcessCustomFiles
*/
private command WASM.ProcessCustomFiles @xResolvedFileData, pCustomFiles, @rCustomFiles
   repeat for each line tKey in the keys of xResolvedFileData
      repeat for each element tCustomFile in pCustomFiles
         if xResolvedFileData[tKey]["resolved"] ends with tCustomFile then
            put xResolvedFileData[tKey]["resolved"] into rCustomFiles[tCustomFile]
            delete variable xResolvedFileData[tKey]
         end if
      end repeat
   end repeat
end WASM.ProcessCustomFiles

----------------------------------------------------------------
-- Stack manipulation functions
----------------------------------------------------------------

/*
* Modifies a copy of <pStackFile> to prepare it for deployment,
* and then returns the modified stack file's contents as data. 
* <pStackFile> is not modified.
*/
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
         # Don't manipulate IDE stacks if for some reason someone
         # tries to put one into a standalone
         put the filename of tStack into tTempFile
         put false into tCleanTempFile
         
      else
         
         -- Get a temporary filename
         put getTemporaryBuildFile(pBuildFolder, ".livecode") into tTempFile
         put true into tCleanTempFile
         
         /* Retain the standalone settings without the deployment password
         * as some widgets, such as map, store the api key here which is needed at runtime.
		*/
         put the customProperties["cRevStandaloneSettings"] of tStack into tStandaloneSettings
         delete variable tStandaloneSettings["password"]
         set the customProperties["cRevStandaloneSettings"] of tStack to tStandaloneSettings      
         
         # Save the modified stack to the temporary file
         lock screen
         
         save tStack as tTempFile with newest format
         put the result into tResult
         if tResult is not empty then
            throw "error saving to" && tTempFile & ":" && tResult
         end if
         
         set the filename of stack tName to pStackFile
         
         # Revert to unmodified state
         
         revert stack tName
         set the defaultStack to tName
         
         unlock screen
         
      end if
      
      open file tTempFile for binary read
      if the result is not empty then
         throw "can't read" && tTempFile & ":" && the result
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

private function q pText
   return quote & pText & quote
end q

----------------------------------------------------------------
-- File & path helper functions
----------------------------------------------------------------

/*
* Map a compiled file's path into an absolute filesystem path.  This
* is used to cope with running from a git repository working tree.
*/
private function mapBinPath pArch, pPath
   if there is a file pPath then
      return pPath
   end if
   
   if revEnvironmentIsInstalled() then
      # We're running from an installed version of LiveCode
      return getRuntimeFolder(pArch) & slash & pPath
   else
      # We're running from a git checkout
      return getRepoBinariesFolder(pArch) & slash & pPath
   end if
end mapBinPath

/*
-- Scan a directory, returning a number-indexed array of files found.
-- The returned paths are relative to the specified directory.
*/
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

/*
* Recursive function used by scanFolder()
*/
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

/*
* Return a number-indexed array of engine files that need to be
* copied into the standalone output folder.
*  pArch : js or wasm
* the version = 9.9.9.
* If this changes then it will have to be changed in both
* standalone-<version>.js and standalone-<version>.html.mem using
*  sed '/9.9.9/newversion/' filename > newfilename
*/
private function getEngineFiles pArch
   local tFilesArray
   
   switch pArch
      case "js"
         -- HTML5 engine JavaScript
         put mapBinPath("js", "standalone-"&the version&".js") \
               into tFilesArray["standalone.js"]
         
         -- HTML5 memory initialisation file
         put mapBinPath("js", "standalone-"&the version&".html.mem") \
               into tFilesArray["standalone-"&the version&".html.mem"]
         -- ICU data
         put mapCommonPath("icudt63l.dat") into tFilesArray["icudt63l.dat"]
         --put mapCommonPath("icudata-minimal.dat") into tFilesArray["icudata-minimal.dat"]
         --put mapCommonPath("icu-core.dat") into tFilesArray["icu-core.dat"]
         --put mapCommonPath("icu-iter.dat") into tFilesArray["icu-iter.dat"]
         --put mapCommonPath("icu-coll.dat") into tFilesArray["icu-coll.dat"]
         break
      case "wasm"
      default
         -- WASM engine JavaScript
         put mapBinPath("wasm", "standalone.js") \
               into tFilesArray["standalone.js"]
         -- WASM engine WebAssembly binary
         put mapBinPath("wasm", "standalone.wasm") \
               into tFilesArray["standalone.wasm"]
         -- ICU data
         put mapCommonPath("icu-core.dat") into tFilesArray["icu-core.dat"]
         put mapCommonPath("icu-iter.dat") into tFilesArray["icu-iter.dat"]
         put mapCommonPath("icu-coll.dat") into tFilesArray["icu-coll.dat"]
         break
   end switch
   
   return tFilesArray
end getEngineFiles

/*
* mapCommonPath
*/
private function mapCommonPath pDatFile
   set the itemdelimiter to slash
   return slash & (item 2 to -2 of the address) & "/Runtime/Common/" & pDatFile
end mapCommonPath

/*
* mapEmscriptenPath
*  pArch : js or wasm
*/
private function mapEmscriptenPath pArch
   set the itemdelimiter to slash
   return slash & (item 2 to -2 of the address) & "/Runtime/Emscripten/" & pArch
end mapEmscriptenPath

/*
* Get the filename of the Emscripten standalone template folder.
* This is a folder that contains the default filesystem
* initialisation data that's automatically included in all
* standalones (especially fonts).
* HTML5 only
*  pArch : js or wasm
*/
private function HTML5.standaloneTemplateFolder pArch
   return mapBinPath(pArch, "emscripten-standalone-template")
end HTML5.standaloneTemplateFolder

/*
* Return a number-indexed array of files in the Emscripten standalone
* template folder.  The paths returned are relative to the path returned
* by HTML5.standaloneTemplateFolder()
# HTML5 only
*/
private function HTML5.StandaloneTemplateFiles
   return scanFolder(HTML5.standaloneTemplateFolder("js"))
end HTML5.StandaloneTemplateFiles

/*
* Get the filename of the Emscripten standalone template HTML file.
* This has some standalone-dependent JavaScript substituted into it to instantiate the engine.
*/
private function getHtmlTemplateFile pArch
   return mapBinPath(pArch, "standalone.html")
end getHtmlTemplateFile

/*
* Get the filename of the Emscripten standalone startup script-only stack template.
*/
private function getStartupTemplateFile pArch
   return mapBinPath(pArch, "emscripten-startup-template.livecodescript")
end getStartupTemplateFile

/*
* Get the directory containing the Emscripten runtime
*/
private function getRuntimeFolder pArch
   
   local tRelFolder, tOverridePath, tUserPath
   
   switch pArch
      case "wasm"
      case "js"
         break
      default
         throw param(0) && "pArch should be js or wasm but is" && pArch
   end switch
   
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

/*
* Get the directory where Emscripten binaries end up (specifically,
* the engine's JavaScript file).
* Get the directory where Emscripten development binaries and resources are installed to.
*/
private function getRepoBinariesFolder pArch
   if pArch is not among the items of "wasm,js" then
      throw the executioncontexts &cr& "pArch should be wasm or js but is" && pArch
   end if
   return mapEmscriptenPath(pArch)
end getRepoBinariesFolder

/*
* Get a temporary filename in <pBuildFolder> with the extension <pExtension>
*/
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
