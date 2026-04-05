script "revDeployLibraryAndroid"

local sAndroidRoot
local sJavaRoot

local sAvailableDevices
#constant kDeployAndroidTargetSDK = "34"
constant kDeployAndroidTargetSDK = "36"
constant kANDROIDARCHS = "armeabi-v7a,arm64-v8a,x86,x86_64"

////////////////////////////////////////////////////////////////////////////////

private command appendToList @xList, pItem
   put pItem into xList[the number of elements in xList]
end appendToList

private command appendToStringList @xList, pItem
   repeat for each line tLine in pItem
      if xList is empty then
         put tLine into xList
      else
         put cr & tLine after xList
      end if
   end repeat
end appendToStringList

////////////////////////////////////////////////////////////////////////////////

command deployInitialize
   deployAutoconfigure

   if sAndroidRoot is not empty then
      revAndroidSetADBPath pathToAdb()
   else
      revAndroidSetADBPath empty
      androidDevicesChanged
   end if
end deployInitialize

function deployListTargets
   local tTargets
   get the keys of sAvailableDevices
   sort it
   repeat for each line tTarget in it
      put "Android" && tTarget & cr after tTargets
   end repeat
   delete the last char of tTargets
   return tTargets
end deployListTargets

function deployIsAvailable?
   local tEnabled?

   if sAvailableDevices is not an array then
      put false into tEnabled?
   else
      put true into tEnabled?
   end if

   return tEnabled?
end deployIsAvailable?

command deployDo pTargetStack, pTargetDevice
   local tError
   put empty into tError

   local tSettings
   put SBGetSettings(pTargetStack, true) into tSettings

   local tIdentifier
   put tSettings["android,identifier"] into tIdentifier
   if tIdentifier is empty then
      put "com.yourcompany.yourapp" into tIdentifier
   end if

   local tDeviceID
   put word 2 to -1 of pTargetDevice into tDeviceID

   if tError is empty then
      revStandaloneProgress "Checking target device architecture..."

      executeShellCommand \
            pathToAdb(), \
            "-s", tDeviceID, \
            "shell", \
            "getprop", \
            "ro.product.cpu.abi"

      local tABI
      put word 1 of line 1 of the result into tABI
      if not (tABI is among the items of kANDROIDARCHS) then
         put "Checking target device architecture failed:" && the result into tError
      end if

      local tArch
      put __ABIArch(tABI) into tArch
      repeat for each item tItem in SBPlatformArchitectures("Android")
         put tItem is tArch into tSettings["Android",tItem]
      end repeat
   end if

   local tTempApksFile
   if tError is empty then
      /* revSaveAsMobileStandalone expects the full path to the target bundle */
      local tTempName
      put tempName() into tTempName
      put tTempName & ".apks" into tTempApksFile
      try
         local tStandalonePaths
         dispatch "saveAsMobileStandalone" to stack "revSaveAsAndroidStandalone" with \
               pTargetStack, \
               tTempName & ".aab", \
               "Test", \
               tSettings, \
               tStandalonePaths, \
               tDeviceID

      catch tException
         put "Unable to build app for testing:" && tException into tError
      end try
   end if

   if tError is empty then
      revStandaloneProgress "Installing app on target device..."

      local tResult
      executeShellCommand pathToJava(), \
            "-jar", \
            pathToBundleTool(), \
            "install-apks", \
            "--apks", tTempApksFile, \
            "--device-id", tDeviceID, \
            "--adb", pathToAdb()
      put the result into tResult

      if not (tResult contains "The APKs have been extracted") then
         put "Installation of app failed:" && tResult into tError
      end if
   else
      throw tError
   end if

   if tError is empty then
      revStandaloneProgress "Launching app on target device..."

      executeShellCommand \
            pathToAdb(), \
            "-s", tDeviceID, \
            "shell", \
            "am", \
            "start", \
            "-n", tIdentifier & "/.mblandroid"
      if the result contains "Error:" then
         put "Launch of app failed:" && the result into tError
      end if
   end if

   if "revStandaloneProgress" is among the lines of the openStacks then
      close stack "revStandaloneProgress"
   end if

   if there is a file tTempApksFile then
      delete file tTempApksFile
   end if

   return tError
end deployDo

private function __ABIArch pABI
   switch pABI
      case "armeabi"
         return "armv6"
      case "armeabi-v7a"
         return "armv7"
      case "arm64-v8a"
         return "arm64"
      case "x86"
      case "x86_64"
         return pABI
   end switch
end __ABIArch

command deployAutoconfigure
   local tSDK
   dispatch function "mobilePreference" to stack "revPreferencesGUI" with "android.sdk"
   put the result into tSDK
   if tSDK is not empty and deploy.IsValidSDK?(tSDK) is not empty then
      put empty into tSDK
   end if
   dispatch "setMobilePreference" to stack "revPreferencesGUI" with "android.sdk", tSDK
   put tSDK into sAndroidRoot

   if sAndroidRoot is not empty then
      local tJDK
      dispatch function "mobilePreference" to stack "revPreferencesGUI" with "android.jdk"
      put the result into tJDK
      if tJDK is empty or deploy.IsValidJDK?(tJDK) is not empty then
         deployAutoconfigureJDK
         put the result into tJDK
      end if
      if tJDK is not empty then
         dispatch "setMobilePreference" to stack "revPreferencesGUI" with "android.jdk", tJDK
         put tJDK into sJavaRoot
      end if
   else
      put empty into sJavaRoot
   end if
end deployAutoconfigure


command deployAutoconfigureJDK
   local tJDK
   switch the platform
      case "win32"
         configureJavaRootWindows
         put the result into tJDK
         break
      case "macos"
         put line 1 of shell("/usr/libexec/java_home") into tJDK
         break
      case "linux"
         break
   end switch

   if deploy.IsValidJDK?(tJDK) is empty then
      return tJDK
   end if

   return empty
end deployAutoconfigureJDK

# TODO: why is this here?
command deployAutoconfigureSDK
   return empty
end deployAutoconfigureSDK

private command androidDevicesChanged
   local tDevices
   put revAndroidListDevices() into tDevices

   put empty into sAvailableDevices
   repeat for each line tDevice in tDevices
      if tDevice contains "no serial number" then
         put quote&quote into word 1 to -2 of tDevice
      end if
      put word 2 of tDevice into sAvailableDevices[word 1 of tDevice]
   end repeat

   revIDEDeployTargetsChanged
end androidDevicesChanged

////////////////////////////////////////////////////////////////////////////////
TODO: fix this... is Java 8 still correct?

/**
* deploy.IsValidJDK?
* parameter:
*  pPath
* returns
*  empty if no error, otherwise an error string
*/

function deploy.IsValidJDK? pPath
   if there is no folder pPath then
      return "could not find registered jdk at" && pPath
   end if

   if there is no file pathToJavaC(pPath) then
      return "missing javac tool, make sure your JDK install has not become corrupted"
   end if

   // newer versions of SDK Tools require Java 8
   if pathToSDKClasses() contains "sdklib-" and not pPath contains "jdk1.8" then
      return "The version of Java installed in your system is not compatible with the current version of Android SDK Tools. Please install Java 8 to continue."
   end if

   return empty
end deploy.IsValidJDK?

function deployTargetSdkVersion
   return kDeployAndroidTargetSDK
end deployTargetSdkVersion

function deploy.RequiredSDK
   local tMap
   put deploy.GetVersionsMap() into tMap
   local tAndroidVersion
   put word 1 of tMap[kDeployAndroidTargetSDK] into tAndroidVersion
   return format("%s (API %s)", tAndroidVersion, kDeployAndroidTargetSDK)
end deploy.RequiredSDK

function deploy.IsValidSDK? pPath
   if there is no folder (pPath & slash & "platforms") then
      return "could not find platforms folder at that path."
   end if

   if there is no folder (pPath & slash & "platform-tools") then
      return "could not find platform-tools folder at that path."
   end if

   if there is no folder (pPath & slash & "build-tools") then
      return "could not find build-tools folder at that path."
   end if

   if there is no folder pathToRootPlatform(pPath) then
      return "could not find install of required target SDK, make sure it has been installed with the Android SDK Manager"
   end if

   if there is no file pathToRootClasses(pPath) then
      return "missing root classes, make sure your SDK install has not become corrupted"
   end if

   if there is no file pathToAapt2(pPath) then
      return "missing aapt2 tool, make sure your SDK install has not become corrupted"
   end if

   if there is no file pathToAdb(pPath) then
      return "missing adb tool, make sure your SDK install has not become corrupted"
   end if

   if there is no file pathToSDKClasses(pPath) then
      --return "missing sdklib.jar, make sure your SDK install has not become corrupted"
   end if

   if there is no file pathToZipAlign(pPath) then
      return "missing zipalign tool, make sure your SDK install has not become corrupted"
   end if

   if there is no file pathToD8(pPath) then
      return "missing d8 tool, make sure your SDK install has not become corrupted"
   end if

   return empty
end deploy.IsValidSDK?

function deploy.GetSDK
   return sAndroidRoot
end deploy.GetSDK

function deploy.GetJDK
   return sJavaRoot
end deploy.GetJDK

////////////////////////////////////////////////////////////////////////////////

function deploy.GetVersionsMap
   local tMap
   put "5.0 - Lollipop" into tMap[21]
   put "5.1" into tMap[22]
   put "6.0 - Marshmallow" into tMap[23]
   put "7.0 - Nougat" into tMap[24]
   --put "7.1" into tMap[25]
   put "8.0 - Oreo" into tMap[26]
   --put "8.1" into tMap[27]
   put "9.0 - Pie" into tMap[28]
   put "10 - Q" into tMap[29]
   put "11 - R" into tMap[30]
   put "12 - S" into tMap[31]
   put "13 - Tiramisu" into tMap[33]
   put "14 - UpsideDownCake" into tMap[34]
   put "15 - VanillaIceCream" into tMap[35]
   put "16 - Baklava" into tMap[36]
   return tMap
end deploy.GetVersionsMap

constant kDefaultMinAPIVersion = 9
function deployGetApiFromVersion pVersion
   local tAPI
   put kDefaultMinAPIVersion into tAPI

   local tMap
   put deploy.GetVersionsMap() into tMap
   repeat for each key tAPIKey in tMap
      if pVersion is tMap[tAPIKey] then
         put tAPIKey into tAPI
         exit repeat
      end if
   end repeat

   return tAPI
end deployGetApiFromVersion

////////////////////////////////////////////////////////////////////////////////

private command executeShellCommand
   local tShell
   repeat with i = 2 to the paramCount
      if param(i) contains space and not (param(i) begins with "-") then
         put quote & param(i) & quote & space after tShell
      else
         put param(i) & space after tShell
      end if
   end repeat

   get doShellCommand(param(1), tShell)

   return it
end executeShellCommand

private function doShellCommand pCommand, pArguments
   local tCommandPath
   set the itemDelimiter to slash
   put item 1 to -2 of pCommand into tCommandPath

   local tOldPath
   put $PATH into tOldPath
   switch the platform
      case "win32"
         replace slash with backslash in tCommandPath
         put tCommandPath & ";" & sJavaRoot & "\bin" & ";" before $PATH
         break
      case "macos"
         put tCommandPath & ":" before $PATH
         break
      case "linux"
         put tCommandPath & ":" & sJavaRoot & "/bin" & ":" before $PATH
         break
   end switch

   set the hideConsoleWindows to true
   get shell(item -1 of pCommand && pArguments)

   put tOldPath into $PATH

   return it
end doShellCommand

private command ensureFolderPath pPath
   if there is a folder pPath then
      exit ensureFolderPath
   end if

   local tParentFolder
   set the itemdelimiter to slash
   put item 1 to -2 of pPath into tParentFolder
   if there is not a folder tParentFolder then
      ensureFolderPath tParentFolder
   end if
   create folder pPath
end ensureFolderPath

////////////////////////////////////////////////////////////////////////////////

private function pathToRootPlatform pRoot
   if pRoot is empty then
      put sAndroidRoot into pRoot
   end if

   # get a list of the folder in the platforms folder
   # return the highest number of "android-<number>"
   return pRoot & slash & "platforms/android-" & kDeployAndroidTargetSDK
end pathToRootPlatform

function pathToRootClasses pRoot
   return pathToRootPlatform(pRoot) & slash & "android.jar"
end pathToRootClasses

function pathToSDKClasses pRoot
   if pRoot is empty then
      put sAndroidRoot into pRoot
   end if
   local tLibs,tSdkLib
   # this should be pRoot/<version>/build-tools/lib
   put files(pRoot&"/build-tools/lib") into tLibs
   if tLibs contains "sdklib.jar" then
      return pRoot & slash & "build-tools/lib/sdklib.jar"
   else
      filter tLibs with "sdklib-[0-9]*" into tSdkLib
      if tSdkLib is empty then return empty
      return pRoot & "/build-tools/lib/" & tSdkLib
   end if
end pathToSDKClasses

function pathToCommonClasses pRoot
   if pRoot is empty then
      put sAndroidRoot into pRoot
   end if
   local tCommonLib
   filter files(pRoot&"/tools/lib") with "common-*" into tCommonLib
   if tCommonLib is empty then return empty
   return pRoot & slash & "tools/lib/" & tCommonLib
end pathToCommonClasses

# older SDK versions have a "tools" folder
private function searchTools pRoot, pCommand
   // search the shared tools folder
   if there is a folder pRoot & slash & "tools" then
      local tPath

      put pRoot & slash & "tools" & slash & pCommand into tPath

      if there is a file tPath then
         return tPath
      end if
   end if
   return empty
end searchTools

function searchBuildTools pRoot, pCommand
   // the build tools folder contains version subfolders containing the actual executables,
   // so we search through each of them starting with the most recent
   --put param(0) && pRoot && pCommand & cr after msg

   if there is a folder pRoot & slash & "build-tools" then
      local tOldFolder, tSDKFolders, tOldItem

      put the folder into tOldFolder
      set the folder to pRoot & slash & "build-tools"

      put the folders into tSDKFolders
      filter tSDKFolders without ".*"
      set the folder to tOldFolder

      return searchSDKbuildtoolsVersionsFor(pCommand, pRoot, tSDKFolders)
   end if
   return empty
end searchBuildTools

private function searchSDKbuildtoolsVersionsFor pCommand, pRoot, pFolders
   local tOldItem
   put the itemdelimiter into tOldItem
   set the itemdelimiter to "."

   // sort version folders descending by x.x.x version numbers
   sort lines of pFolders descending numeric by item 3 of each
   sort lines of pFolders descending numeric by item 2 of each
   sort lines of pFolders descending numeric by item 1 of each

   set the itemdelimiter to tOldItem

   local tPath
   repeat for each line tVersion in pFolders
      put pRoot & slash & "build-tools" & slash & tVersion & slash & pCommand into tPath
      if there is a file tPath then
         return tPath
      end if
   end repeat
   return empty
end searchSDKbuildtoolsVersionsFor

function searchMobileRuntimeFolder pCommand
   local tPath
   put revEnvironmentUserRuntimePath() & slash & "Android" & slash & pCommand into tPath
   if there is a file tPath then return tPath

   put environment.RuntimePath() & slash & "Android" & slash & pCommand into tPath
   if there is a file tPath then return tPath

   return empty
end searchMobileRuntimeFolder

constant kWindowsBatchCommands = "apksigner,d8"
private function executableName pCommand
   if the platform is "win32" then
      if pCommand is among the items of kWindowsBatchCommands then
         return pCommand & ".bat"
      else
         return pCommand & ".exe"
      end if
   else
      return pCommand
   end if
end executableName

private function pathToBuildTool pRoot, pCommand
   if pRoot is empty then
      put sAndroidRoot into pRoot
   end if

   -- IM-2013-05-21: Update to look in "build-tools/<version>" folder
   local tPath
   put searchBuildTools(pRoot, pCommand) into tPath
   if tPath is not empty then return tPath

   local tOldFolder, tFolders, tOldItem

   put the folder into tOldFolder
   set the folder to pRoot & slash & "build-tools"

   put the folders into tFolders

   set the folder to tOldFolder
   return searchSDKbuildtoolsVersionsFor(pCommand, pRoot, tFolders)

   -- MM-2011-08-09: Update to look in platform-tools folder if not present in platforms/android-8/tools/
#   if there is a file pRoot & slash & "platforms/android-8/tools/" & pCommand then
#      return pRoot & slash & "platforms/android-8/tools/" & pCommand
#   end if

#   return pRoot & slash & "platform-tools/" & pCommand
   return pathToPlatformTool(pRoot, pCommand)
end pathToBuildTool

private function pathToPlatformTool pRoot, pCommand
   if pRoot is empty then
      put sAndroidRoot into pRoot
   end if
   return pRoot & slash & "platform-tools" & slash & executableName(pCommand)
end pathToPlatformTool

private function pathToJavaExecutable pRoot, pCommand
   if pRoot is empty then
      put sJavaRoot into pRoot
   end if
   return pRoot & slash & "bin" & slash & pCommand
end pathToJavaExecutable

function pathToAapt2 pRoot
   return pathToBuildTool(pRoot, executableName("aapt2"))
end pathToAapt2

function pathToAdb pRoot
   return pathToPlatformTool(pRoot, executableName("adb"))
end pathToAdb

function pathToAPKSigner pRoot
   return pathToBuildTool(pRoot, executableName("apksigner"))
end pathToAPKSigner

function pathToDebugKey pRoot
   return specialFolderPath("home") & "/.android/debug.keystore"
end pathToDebugKey

# pRoot here is ~/Android/Sdk
function pathToZipAlign pRoot
   return pathToBuildTool(pRoot, executableName("zipalign"))
end pathToZipAlign

function pathToD8 pRoot
   return pathToBuildTool(pRoot, executableName("d8"))
end pathToD8

# pRoot should be "android-studio/jbr"
function pathToJavaC pRoot
   return pathToJavaExecutable(pRoot, executableName("javac"))
end pathToJavaC

function pathToJava pRoot
   return pathToJavaExecutable(pRoot, executableName("java"))
end pathToJava

function pathToJarSigner pRoot
  return pathToJavaExecutable(pRoot, executableName("jarsigner"))
end pathToJarSigner

function pathToJar pRoot
  return pathToJavaExecutable(pRoot, executableName("jar"))
end pathToJar

function pathToKeytool pRoot
  return pathToJavaExecutable(pRoot, executableName("keytool"))
end pathToKeytool

// BundleTool
// https://github.com/google/bundletool/releases/download/1.8.0/bundletool-all-1.8.0.jar
constant kBundleToolDownloadURL = "https://github.com/google/bundletool/releases/download"
constant kBundleToolVersion = "1.18.1"

function pathToBundleTool
   local tCacheDir, tBundleToolJar
   put pathToBundleToolDir() into tCacheDir
   put tCacheDir & slash & "bundletool-all-" & kBundleToolVersion & ".jar" into tBundleToolJar

   if there is not a file tBundleToolJar then
      fetchBundleTool tBundleToolJar
   end if

   return tBundleToolJar
end pathToBundleTool

private function pathToBundleToolDir
   local tCachePath
   put environment.UserCachePath() & slash & "Android" & slash & "bundletool" into tCachePath
   ensureFolderPath tCachePath
   return tCachePath
end pathToBundleToolDir

private command fetchBundleTool pOutputFile
   local tFileData
   put downloadBundleTool() into tFileData

   if tFileData is empty then
      throw "unable to fetch bundletool.jar"
   end if

   set the itemDelimiter to slash
   ensureFolderPath (item 1 to -2 of pOutputFile)
   put tFileData into url ("binfile:" & pOutputFile)
end fetchBundleTool

private function downloadBundleTool
   local tUrl
   put kBundleToolDownloadURL & slash & kBundleToolVersion & slash & \
      "bundletool-all-" & kBundleToolVersion & ".jar" into tUrl

   return fetchTool(tUrl)

#   local tFileData
#   load url tUrl
#   local tDownloading? = true
#   local tFailed? = false
#   repeat while tDownloading?
#      wait 0 milliseconds with messages
#      local tStatus
#      put the urlstatus of tUrl into tStatus
#      switch tStatus
#         case "cached"
#            put false into tDownloading?
#            break
#         case "error"
#         case "timeout"
#            put false into tDownloading?
#            put true into tFailed?
#            break
#      end switch
#   end repeat

#   if tFailed? then
#      return empty
#   end if

#   put url tUrl into tFileData
#   return tFileData
end downloadBundleTool

private function fetchTool pUrl
   local tFileData
   load url pUrl
   local tDownloading? = true
   local tFailed? = false
   repeat while tDownloading?
      wait 0 milliseconds with messages
      local tStatus
      put the urlstatus of pUrl into tStatus
      switch tStatus
         case "cached"
            put false into tDownloading?
            break
         case "error"
         case "timeout"
            put false into tDownloading?
            put true into tFailed?
            break
      end switch
   end repeat

   if tFailed? then
      return empty
   end if

   put url pUrl into tFileData
   return tFileData
end fetchTool


////////////////////////////////////////////////////////////////////////////////

// Maven Library Archives

private function pathToLocalRepo pRoot
   if pRoot is empty then
      put sAndroidRoot into pRoot
   end if
   return pRoot & slash & "extras/google/m2repository"
end pathToLocalRepo

private function formatDependencyPath pPackage, pName, pVersion, pType
   replace "." with slash in pPackage
   return pPackage & slash & pName & slash & pVersion & slash & pName & "-" & pVersion & "." & pType
end formatDependencyPath

private function pathToLocalDependency pRoot, pPackage, pName, pVersion, pType
   local tFilepath
   put pathToLocalRepo(pRoot) & slash & formatDependencyPath(pPackage, pName, pVersion, pType) into tFilepath
   if there is not a file tFilepath then
      return empty
   end if
   return tFilepath
end pathToLocalDependency

private function pathToDependencyCache
   local tCachePath
   put environment.UserCachePath() & slash & "Android" & slash & "Repository" into tCachePath
   ensureFolderPath tCachePath
   if there is not a folder tCachePath then
      return empty
   end if

   return tCachePath
end pathToDependencyCache

private function pathToCachedDependency pPackage, pName, pVersion, pType
   local tPath
   put pathToDependencyCache() into tPath
   if tPath is empty then
      return empty
   end if

   put slash & formatDependencyPath(pPackage, pName, pVersion, pType) after tPath
   if there is not a file tPath then
      fetchRemoteDependency pPackage, pName, pVersion, pType, tPath
      // Check if fetching failed
      if there is not a file tPath then
         return empty
      end if
   end if

   return tPath
end pathToCachedDependency

local sDownloadCallback
on _fechMavenFileCallback
   if sDownloadCallback is not empty then
      dispatch sDownloadCallback["callback"] to sDownloadCallback["object"] with sDownloadCallback["context"]
   end if
end _fechMavenFileCallback

private function fetchMavenFile pRepo, pPath
   local tUrl
   put pRepo & slash & pPath into tUrl

   return fetchTool(tUrl)

#   local tFileData
#   load url tUrl with message "_fetchMavenFileCallback"
#   local tDownloading? = true
#   local tFailed? = false
#   repeat while tDownloading?
#      wait 0 milliseconds with messages
#      local tStatus
#      put the urlstatus of tUrl into tStatus
#      switch tStatus
#         case "cached"
#            put false into tDownloading?
#            break
#         case "error"
#         case "timeout"
#            put false into tDownloading?
#            put true into tFailed?
#            break
#      end switch
#   end repeat

#   if tFailed? then
#      return empty
#   end if

#   put url tUrl into tFileData
#   return tFileData
end fetchMavenFile

constant kMavenRepo = "https://repo1.maven.org/maven2"
constant kGoogleRepo = "https://dl.google.com/android/maven2"
private command fetchRemoteDependency pPackage, pName, pVersion, pType, pOutputFile
   local tDepPath
   put formatDependencyPath(pPackage, pName, pVersion, pType) into tDepPath

   local tFileData
   put fetchMavenFile(kGoogleRepo, tDepPath) into tFileData
   if tFileData is empty then
      put fetchMavenFile(kMavenRepo, tDepPath) into tFileData
   end if

   if tFileData is empty then
      throw "unable to fetch dependency file " & pPackage & "." & pName & "-" & pVersion & "." & pType
   end if

   set the itemDelimiter to slash
   ensureFolderPath (item 1 to -2 of pOutputFile)
   put tFileData into url ("binfile:" & pOutputFile)
end fetchRemoteDependency

//////////

private function depKey pGroup, pArtifact
   return pGroup,pArtifact
end depKey

private function compareVersion pA, pB
   // compare only numeric part of version string
   set the itemdelimiter to "-"
   local tOldA, tOldB
   put pA into tOldA
   put pB into tOldB
   put item 1 of pA into pA
   put item 1 of pB into pB
   repeat with i = 1 to 3
      local tA, tB
      set the itemdelimiter to "."
      put item i of pA into tA
      put item i of pB into tB
      if tA is empty then put 0 into tA
      if tB is empty then put 0 into tB
      local tDiff
      if tA is not a number or tB is not a number then
         throw "compareVersion: can't compare " & tOldA & " with " & tOldB
      end if
      put tA - tB into tDiff
      if tDiff is not 0 then
         return tDiff
      end if
   end repeat
   // No difference - return 0
   return 0
end compareVersion

constant kXMLError = "xmlerr,"
constant kXMLErrorCantFindElement = "xmlerr, can't find element"
private function _revXMLNodeContentsWithDefault pTree, pNode, pDefaultValue
   local tValue
   put revXMLNodeContents(pTree, pNode) into tValue
   if tValue begins with kXMLError then
      if tValue is kXMLErrorCantFindElement then
         put pDefaultValue into tValue
      end if
   end if
   return tValue
end _revXMLNodeContentsWithDefault

private function _revXMLNodeContentsOrThrow pTree, pNode, pErrorMessage
   local tValue
   put revXMLNodeContents(pTree, pNode) into tValue
   if tValue begins with kXMLError then
      throw pErrorMessage
   end if
   return tValue
end _revXMLNodeContentsOrThrow

private function parsePOMDependencyList pTree, pNode
   local tDependencyNode, tDependencies
   put revXMLFirstChild(pTree, pNode) into tDependencyNode
   if tDependencyNode begins with kXMLError then
      put empty into tDependencyNode
   end if
   repeat while tDependencyNode is not empty
      local tDependency
      put _revXMLNodeContentsOrThrow(pTree, tDependencyNode & "/groupId", "missing dependency groupId") into tDependency["groupId"]
      put _revXMLNodeContentsOrThrow(pTree, tDependencyNode & "/artifactId", "missing dependency artifactId") into tDependency["artifactId"]
      local tVersion, tScope
      put _revXMLNodeContentsWithDefault(pTree, tDependencyNode & "/version", empty) into tVersion
      if tVersion is not empty then
         put tVersion into tDependency["version"]
      end if
      put _revXMLNodeContentsWithDefault(pTree, tDependencyNode & "/scope", empty) into tScope
      if tScope is not empty then
         put tScope into tDependency["scope"]
      end if

      appendToList tDependencies, tDependency

      put revXMLNextSibling(pTree, tDependencyNode) into tDependencyNode
   end repeat

   return tDependencies
end parsePOMDependencyList

private function parsePOMFile pPomFile
   local tPOM, tError
   local tTreeId, tDependencies
   put revXMLCreateTreeFromFile(pPomFile, false, true, false) into tTreeId
   if tTreeId begins with "xmlerr" then
      throw "Error parsing POM file " & quote & pPomFile & quote & " - " & tTreeId
   end if

   try
      local tChildNodes
      put revXMLChildNames(tTreeId, "/project", comma, empty, false) into tChildNodes

      if "packaging" is among the items of tChildNodes then
         put _revXMLNodeContentsOrThrow(tTreeId, "/project/packaging", empty) into tPOM["packaging"]
      end if

      local tParent
      if "parent" is among the items of tChildNodes then
         put _revXMLNodeContentsOrThrow(tTreeId, "project/parent/groupId", "missing parent groupId") into tPOM["parent"]["groupId"]
         put _revXMLNodeContentsOrThrow(tTreeId, "project/parent/artifactId", "missing parent artifactId") into tPOM["parent"]["artifactId"]
         put _revXMLNodeContentsOrThrow(tTreeId, "project/parent/version", "missing parent version") into tPOM["parent"]["version"]
      end if

      if "dependencies" is among the items of tChildNodes then
         put parsePOMDependencyList(tTreeId, "project/dependencies") into tDependencies
         if tDependencies is not empty then
            put tDependencies into tPOM["dependencies"]
         end if
      end if

      if "dependencyManagement" is among the items of tChildNodes then
         put parsePOMDependencyList(tTreeId, "project/dependencyManagement/dependencies") into tDependencies
         if tDependencies is not empty then
            put tDependencies into tPOM["dependencyManagement"]["dependencies"]
         end if
      end if
   catch tException
      put "Error parsing POM file: " & tException into tError
   finally
      revXMLDeleteTree(tTreeId)
   end try

   if tError is not empty then
      throw tError
   end if

   return tPOM
end parsePOMFile

private function getPOM pRoot, pGroup, pArtifact, pVersion
   // fetch library POM file
   local tPomFile
   put pathToAndroidDependency(pRoot, pGroup, pArtifact, pVersion, "pom") into tPomFile

   local tPOM
   put parsePOMFile(tPomFile) into tPOM

   if tPOM["parent"] is not empty then
      local tParentPOM
      put getPOM(pRoot, tPOM["parent"]["groupId"], tPOM["parent"]["artifactId"], tPOM["parent"]["version"]) into tParentPOM
      mergePOMParent tPOM, tParentPOM
   end if

   return tPOM
end getPOM

private command mergePOMParent @xPOM, pParentPOM
   repeat for each item tKey in "group,version,dependencyManagement"
      if xPOM[tKey] is empty and pParentPOM[tKey] is not empty then
         put pParentPOM[tKey] into xPOM[tKey]
      end if
   end repeat
end mergePOMParent

private command parseVersionRanges pVersion, @rRanges, @rDefault
   local tRange, tRanges, tDefault
   if char 1 of pVersion is among the chars of "([" then
      local tCharIndex = 1
      repeat while tCharIndex <= the number of chars in pVersion
         local tChar, tVersion, tRelation, tLimit
         put char tCharIndex of pVersion into tChar
         add 1 to tCharIndex
         switch tChar
            case "("
               put ">" into tRelation
               break
            case "["
               put ">=" into tRelation
               break
            case ","
               if tRelation is not empty then
                  put tRelation into tLimit["relation"]
                  put tVersion into tLimit["version"]
                  appendToList tRange, tLimit
                  put empty into tRelation
                  put empty into tVersion
               else
                  appendToList tRanges, tRange
               end if
               break
            case ")"
               if tRelation is not empty then
                  put tRelation into tLimit["relation"]
                  put tVersion into tLimit["version"]
                  appendToList tRange, tLimit
               end if
               put "<" into tRelation
               put tRelation into tLimit["relation"]
               put tVersion into tLimit["version"]
               appendToList tRange, tLimit
               put empty into tRelation
               put empty into tVersion
               appendToList tRanges, tRange
               put empty into tRange
               break
            case "]"
               if tRelation is not empty then
                  put tRelation into tLimit["relation"]
                  put tVersion into tLimit["version"]
                  appendToList tRange, tLimit
               end if
               put "<=" into tRelation
               put tRelation into tLimit["relation"]
               put tVersion into tLimit["version"]
               appendToList tRange, tLimit
               put empty into tRelation
               put empty into tVersion
               appendToList tRanges, tRange
               put empty into tRange
               break
            default
               put tChar after tVersion
               break
         end switch
      end repeat

      repeat for each element tRange in tRanges
         // If a range is limited to a single version then use that as default
         if tRange[0]["relation"] is ">=" and \
               tRange[1]["relation"] is "<=" and \
               tRange[0]["version"] is tRange[1]["version"] then
            put tRange[1]["version"] into tDefault
         end if
      end repeat
   else
      // Plain version number is interpreted as x >= <version> with <version> as default
      put ">=" into tRange["relation"]
      put pVersion into tRange["version"]
      appendToList tRanges, tRange
      put pVersion into tDefault
   end if
   put tRanges into rRanges
   put tDefault into rDefault
end parseVersionRanges

function resolvePOMDependency pDependency, pDependencyManagement
   if pDependencyManagement is not empty then
      repeat for each element tDefault in pDependencyManagement["dependencies"]
         if tDefault["groupId"] is pDependency["groupId"] and tDefault["artifactId"] is pDependency["artifactId"] then
            local tDependency
            union pDependency with tDefault into tDependency
            return tDependency
         end if
      end repeat
   end if
   return pDependency
end resolvePOMDependency

# NOTE: pContext is always empty
command setMavenDownloadCallback pCallbackHandler, pCallbackObjectID, pCallbackContext
   local tCallback
   if pCallbackHandler is empty then
      put empty into tCallback
   else
      put pCallbackHandler into tCallback["handler"]
      put pCallbackObjectId into tCallback["objectId"]
      put pCallbackContext into tCallback["context"] # always empty
   end if
   put tCallback into sDownloadCallback
end setMavenDownloadCallback

constant kPOMRuntimeScopes = "compile,runtime"

command resolveAndroidLibraryDependencyList @xDependencies, pRoot, pDependencyList
   local tDependencyList, tNewDependencyList
   put pDependencyList into tDependencyList
   repeat while tDependencyList is not empty
      repeat for each line tDependencyLine in tDependencyList
         local tGroupId, tArtifactId, tVersion
         split tDependencyLine by ":"
         put tDependencyLine[1] into tGroupId
         put tDependencyLine[2] into tArtifactId
         put tDependencyLine[3] into tVersion

         local tDepKey
         put depKey(tGroupId, tArtifactId) into tDepKey
         if xDependencies[tDepKey] is not empty then
            next repeat
         end if

         // Decide which version to use - here we just use the suggested or default version
         local tVersionRanges, tDefaultVersion
         parseVersionRanges tVersion, tVersionRanges, tDefaultVersion
         put tDefaultVersion into tVersion

         put tVersion into xDependencies[tDepKey]["version"]

         // fetch library POM, extract library file type and dependencies
         local tPOM
         put getPOM(pRoot, tGroupId, tArtifactId, tVersion) into tPOM

         local tType
         put tPOM["packaging"] into tType
         if tType is empty then put "jar" into tType
         switch tType
            case "aar"
            case "jar"
               put tType into xDependencies[tDepKey]["type"]
               break
            case "bundle"
               // Bundle projects produce jar files
               put "jar" into xDependencies[tDepKey]["type"]
               break
            case "pom"
               // Used for "parent" POMs
               break
         end switch

         // add POM dependencies to check on next iteration
         if tPOM["dependencies"] is not empty then
            repeat for each element tDep in tPOM["dependencies"]
               put resolvePOMDependency(tDep, tPOM["dependencyManagement"]) into tDep
               if tDep["scope"] is among the items of kPOMRuntimeScopes then
                  put format( \
                        "%s:%s:%s\n", \
                        tDep["groupId"],\
                        tDep["artifactId"], \
                        tDep["version"]) \
                     after tNewDependencyList
               end if
            end repeat
         end if
      end repeat

      put tNewDependencyList into tDependencyList
      put empty into tNewDependencyList
   end repeat
end resolveAndroidLibraryDependencyList

command fetchAndroidLibraryDependencies pRoot, pDependencies, @xJarFiles, @xAarFiles
   repeat for each key tDep in pDependencies
      local tGroup, tArtifact, tVersion, tType
      put item 1 of tDep into tGroup
      put item 2 of tDep into tArtifact
      put pDependencies[tDep]["version"] into tVersion
      put pDependencies[tDep]["type"] into tType
      if tType is not empty then
         local tDepFile
         put pathToAndroidDependency(pRoot, tGroup, tArtifact, tVersion, tType) into tDepFile
         if tType is "jar" then
            appendToStringList xJarFiles, tDepFile
         else if tType is "aar" then
            appendToStringList xAarFiles, tDepFile
         end if
      end if
   end repeat
end fetchAndroidLibraryDependencies

private function pathToAndroidDependency pRoot, pPackage, pName, pVersion, pType
   local tPath
   put pathToLocalDependency(pRoot, pPackage, pName, pVersion, pType) into tPath
   if tPath is not empty then
      return tPath
   end if

   put pathToCachedDependency(pPackage, pName, pVersion, pType) into tPath
   if tPath is not empty then
      return tPath
   end if

   return empty
end pathToAndroidDependency

////////////////////////////////////////////////////////////////////////////////

private command configureJavaRootWindows
   local tVersion, tIs64Bit?
   put true into tIs64Bit?
   put getRegistryValue("HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit", "CurrentVersion", tIs64Bit?) into tVersion
   if tVersion is empty then
      put false into tIs64Bit?
      put getRegistryValue("HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit", "CurrentVersion", tIs64Bit?) into tVersion
   end if

   local tJavaHome
   put getRegistryValue("HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit\" & tVersion, "JavaHome", tIs64Bit?) into tJavaHome

   return tJavaHome
end configureJavaRootWindows

private function getRegistryValue pKey, pValue, pUse64Bit?
   local tRegCmd, tValue
   if pUse64Bit? then
      put $SystemRoot & slash & "sysnative" & slash & "reg.exe" into tRegCmd
      if there is no file tRegCmd then
         return empty
      end if
   else
      put "reg.exe" into tRegCmd
   end if
   set the hideConsoleWindows to true

   // IM 12/05/2011 - added check for error return from reg.exe
   // reg.exe returns an error if the key or value is not found

   //return word 3 to -1 of the last line of (word 1 to -1 of shell(tRegCmd && "QUERY" && quote & pKey & quote && "/v" && quote & pValue & quote))
   put the last line of (word 1 to -1 of shell(tRegCmd && "QUERY" && q(pKey) && "/v" && q(pValue))) into tValue
   if word 1 of tValue is "ERROR:" then
      return empty
   end if
   return word 3 to -1 of tValue
end getRegistryValue

# never used ? : mdw 2025.07.12
private function listRegistryRecursive pKey, pUse64Bit?
   local tRegCmd
   if pUse64Bit? then
      put $SystemRoot & slash & "sysnative" & slash & "reg.exe" into tRegCmd
   else
      put empty into tRegCmd
   end if
   if there is no file tRegCmd then
      put "reg.exe" into tRegCmd
   end if

   local tKeys
   put word 1 to -1 of shell(tRegCmd && "QUERY" && quote & pKey & quote && "/s") into tKeys

   local tCurrentKey, tKeyArray
   repeat for each line tLine in tKeys
      put word 1 to -1 of tLine into tLine
      if tLine is empty then
         next repeat
      end if

      if tLine begins with " " then
         put word 3 to -1 of tLine into tKeyArray[tCurrentKey]
      else
         put tLine into tCurrentKey
         delete char 1 to the number of chars of pKey + 1 of tCurrentKey
      end if
   end repeat

   return tKeyArray
end listRegistryRecursive
