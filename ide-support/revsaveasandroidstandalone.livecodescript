script "revSaveAsAndroidStandalone"
################################################################################

local sJavaRoot

################################################################################

command saveAsMobileStandalone \
      pStack, \
      pAabFile, \
      pTarget, \
      pSettings, \
      @xStandalonePaths, \
      pDevice
   
   local tPath
   put the cMobileSupport["android.sdk"] of stack "revPreferences" into tPath
   
   if tPath is empty then
      throw revIDELocalise("In order to build Android standalones" & \ 
            " you need to choose the location of your Android development SDK" & \
            " in Preferences -> Mobile Support")
   end if
   if not revIDEDeployAndroidIsValidSDK(tPath) then
      throw revIDELocalise("The chosen folder in Preferences -> Mobile Support" & \
            " is not a valid Android SDK. Please ensure you have installed it correctly," & \
            " and enabled support for") && deploy.Android.RequiredSDK()
   end if
   
   local tTargetType
   if pTarget contains "build" then
      put "android release" into tTargetType
   else
      put "android test" into tTargetType
   end if
   
   local tPackage
   put pAabFile into tPackage
   if not pSettings["android,use bundle"] then
      set the itemDelimiter to "."
      put "apk" into the last item of tPackage
      set the itemDelimiter to ","
   end if
   
   try
      put the cMobileSupport["android.jdk"] of stack "revPreferences" into sJavaRoot
      dispatch "savingMobileStandalone" to stack pStack with tTargetType, tPackage
   end try
   
   try
      saveAsMobileStandaloneMain pStack, pAabFile, pTarget, pSettings,pDevice
   catch tError
   end try
   
   try
      if tError is not empty then
         put empty into tPackage
      end if
      dispatch "mobileStandaloneSaved" to stack pStack with tTargetType, tPackage
   end try
   
   if tError is not empty then
      throw tError
   end if
end saveAsMobileStandalone

private function pathIsRelative pPath
   if pPath is empty then throw "empty path"
   if pPath begins with "/" then return false
   if char 2 of pPath is ":" then return false
   
   return true
end pathIsRelative

// IM-2013-05-21: [[ BZ 10904 ]] This function replicates the functionality of the apkbuilder script which has now been removed from the Android SDK platform tools
private command buildAPK pUnalignedApkFile, pUnsignedParam, pAssetArchive, pClassesFile, pLibsBuildFolder
   local tResult, tSep
   if the platform is "Win32" then 
      put ";" into tSep
   else
      put ":" into tSep
   end if
   
   // We need the 'common' classes to fix the following exception
   /*
   Exception in thread "main" java.lang.NoClassDefFoundError: com/android/prefs/AndroidLocation
	at com.android.sdklib.internal.build.DebugKeyProvider.getDefaultKeyStoreOsPath(DebugKeyProvider.java:122)
	at com.android.sdklib.build.ApkBuilder.getDebugKeystore(ApkBuilder.java:944)
	at com.android.sdklib.build.ApkBuilderMain.main(ApkBuilderMain.java:129)
    Caused by: java.lang.ClassNotFoundException: com.android.prefs.AndroidLocation
   */
   local tParams
   appendToParams tParams, "-Xmx128M"
   appendToParams tParams, "-classpath", pathToSDKClasses() & tSep & pathToCommonClasses()
   appendToParams tParams, "com.android.sdklib.build.ApkBuilderMain"
   appendToParams tParams, pUnalignedApkFile
   if pUnsignedParam is not empty then
      appendToParams tParams, pUnsignedParam
   end if
   appendToParams tParams, "-v"
   appendToParams tParams, "-z", pAssetArchive
   appendToParams tParams, "-z", pClassesFile
   appendToParams tParams, "-nf", pLibsBuildFolder

   executeShellCommandWithParams pathToJava(), tParams
   put the result into tResult
   return tResult
end buildAPK

private function updateMinimumAPI pVersionSet, pLimit
   local tLimitType
   if pVersionSet < pLimit then
      put "lowest" into tLimitType
   else
      put "highest" into tLimitType
   end if
   
   answer "The minimum Android API is currently set to" && \
         pVersionSet && \
         "but the" && tLimitType & " Android API available from LiveCode" && the version && \
         "is" && pLimit & "." & LF & \
         "Do you want to update the minimum Android API to" && pLimit & "?" \
         with "No" or "Yes" \
         titled "Minimum Android API error"
   
   return (it is "Yes")
end updateMinimumAPI

private function badAndroidApiMessage
   return "Not a valid Android API"
end badAndroidApiMessage

private function __ArchABI pArch
   switch pArch
      case "armv6"
         return "armeabi"
      case "armv7"
         return "armeabi-v7a"
      case "arm64"
         return "arm64-v8a"
      case "x86"
      case "x86_64"
         return pArch
   end switch
end __ArchABI

constant kAndroidExternals = "revzip revxml dbsqlite dbmysql dbodbc dbpostgresql revpdfprinter"

private function AmazonBillingReceiver
   local tAmazonReceiver
   put "<receiver android:name="&quote&"com.amazon.inapp.purchasing.ResponseReceiver" & quote & \
         " android:exported=" & quote & "true" & quote & ">" into tAmazonReceiver
   put "<intent-filter>" & return after tAmazonReceiver
   put "<action android:name="&quote&"com.amazon.inapp.purchasing.NOTIFY"&quote&" " & cr after tAmazonReceiver
   put "android:permission ="&quote&"com.amazon.inapp.purchasing.Permission.NOTIFY"&quote&"  />" & cr after tAmazonReceiver
   put "</intent-filter>" after tAmazonReceiver
   put "</receiver>" after tAmazonReceiver
   return tAmazonReceiver
end AmazonBillingReceiver

private command saveAsMobileStandaloneMain \
      pStack, \
      pAabFile, \
      pTarget, \
      pSettings, \
      pDevice
   
   local tArchABIs, tArchs
   repeat for each item tItem in revSBPlatformArchitectures("Android")
      if pSettings["android",tItem] then
         put true into tArchABIs[__ArchABI(tItem)]
         put true into tArchs[tItem]
      end if
   end repeat
   if the number of elements of tArchABIs is 0 then
      put true into tArchABIs["armeabi-v7a"]
      put true into tArchs["armv7"]
   end if
   combine tArchABIs by comma as set
   combine tArchs by comma as set
   
   dispatch "deploy.Android.Initialize" to stack "revDeployLibrary"
   
   -- If we're searching for inclusions, do it here 
   local tConfirm, tResult
   put true into tConfirm
   if pSettings["inclusions"] is "search" then 
      put false into tConfirm
      -- search for inclusions when building for simulator
      if pTarget contains "test" then
         revSBSearchForInclusions pStack, pSettings
      end if
      
   end if
   
   -- Make sure all dependencies are included
   revSBUpdateForDependencies "android", tArchs, , pSettings
   revSBEnsurePerExtensionSettings "android", pSettings
   put the result into tResult
   if tResult is not empty then
      throw tResult
   end if
   
   -- Manually remove built-in implementations from detected script library inclusions
   revSBRemoveInclusions pStack, "android", tConfirm, pSettings
   
   -- Make sure old-style keys are retained, and updated with new information
   -- from inclusions pane of standalone settings GUI
   revSBConvertSettingsForPlatform pSettings, "android"
   
   -- Compute the base folder
   local tBaseFolder
   set the itemDelimiter to slash
   put item 1 to -2 of the effective filename of stack pStack into tBaseFolder
   set the itemDelimiter to comma
   
   -- Fetch the various options we need to initially build the app-bundle
   local tName, tVersionName, tVersionCode, tExternals, tDrivers
   local tIcon, tKey, tUseDebugKey, tStatusBarIcon
   put pSettings["name"] into tName
   put pSettings["android,icon"] into tIcon
   put pSettings["android,key"] into tKey
   
   if pSettings["android,label"] is empty then
      put tName into pSettings["android,label"]
   end if
   if pSettings["android,identifier"] is empty then
      put "com.yourcompany.yourapp" into pSettings["android,identifier"]
   end if
   if pSettings["android,version name"] is empty then
      put "1.0.0" into pSettings["android,version name"]
   end if
   if pSettings["android,version code"] is empty then
      put "1" into pSettings["android,version code"]
   end if
   if pSettings["android,initial orientation"] is empty then
      put "portrait" into pSettings["android,initial orientation"]
   end if
   if pSettings["android,status bar hidden"] is empty then
      put "false" into pSettings["android,status bar hidden"]
   end if
   
   // SN-2015-05-13: [[ AndroidVersions ]] Make sure that the minimum version is
   // the minimum version that we can use.
   local tMinimumVersion, tMaximumVersion
   put item 1 of deploy.Android.GetApisList() into tMinimumVersion
   put last item of deploy.Android.GetApisList() into tMaximumVersion
   
   if pSettings["android,minimum version"] is empty then
      put tMinimumVersion into pSettings["android,minimum version"]
   else if pSettings["android,minimum version"] < tMinimumVersion then
      // In case the minimum version is still 2.2 (for instance), we warn the user
      //  that we want to update it, before doing so.
      if updateMinimumAPI(pSettings["android,minimum version"], tMinimumVersion) then
         put tMinimumVersion into pSettings["android,minimum version"]
      else
         throw badAndroidAPIMessage()
      end if
   else if pSettings["android,minimum version"] > tMaximumVersion then
      if updateMinimumAPI(pSettings["android,minimum version"], tMaximumVersion) then
         put tMaximumVersion into pSettings["android,minimum version"]
      else
         throw badAndroidAPIMessage()
      end if
   end if
   
   put pSettings["android,statusBarIcon"] into tStatusBarIcon
   if tStatusBarIcon is empty then
      // put default sb icon path into tStatusBarIcon
      // SN-2015-01-22: [[ Bug 13213 ]] If mapFilePath returns empty, an error will be triggered
      // line 629.
      put mapFilePath(revMobileRuntimeFolder(pTarget) & slash & "notify_icon.png") into tStatusBarIcon
   end if
   
   local tUseFirebaseMessaging, tUseGoogleServices
   if pSettings["android,enablePushNotification"] then
      // Push notification on Android requires both firebase-messaging and google-services libraries
      put true into tUseFirebaseMessaging
      put true into tUseGoogleServices
   end if
   
   if tUseFirebaseMessaging then
      // Add firebase messaging dependencies to settings
      appendToStringList ("com.google.firebase", "firebase-messaging", "22.0.0"), pSettings["android,android dependencies"]
   end if
   
   if tUseGoogleServices then
      // Add google play services dependencies to settings
      appendToStringList ("com.google.gms", "google-services", "4.3.8"), pSettings["android,android dependencies"]
   end if
   
   if pSettings["android,inAppPurchasing"] and pSettings["android,billingProvider"] is "Google" then
      appendToStringList ("com.android.billingclient", "billing", "5.2.1"), pSettings["android,android dependencies"]
   end if
   
   switch pSettings["android,signing"]
      case "sign with my key"
         break
      case "sign for development only"
         put true into tUseDebugKey
         put empty into tKey
         break;
      case "do not sign"
         put false into tUseDebugKey
         put empty into tKey
         break
      default
         break
   end switch
   
   -- Compute the icon path
   if tIcon is not empty and pathIsRelative(tIcon) then
      put tBaseFolder & slash before tIcon
   end if
   
   -- Compute the key path
   if tKey is not empty and pathIsRelative(tKey) then
      put tBaseFolder & slash before tKey
   end if
   
   -- Compute the status bar icon path
   if tStatusBarIcon is not empty and pathIsRelative(tStatusBarIcon) then
      put tBaseFolder & slash before tStatusBarIcon
   end if
   
   -- Compute the externals list (includes drivers on Android)
   repeat for each word tExternal in kAndroidExternals
      if pSettings["android,include" && tExternal] then
         if tExternal begins with "db" then 
            if "revdb" is not among the lines of tExternals then
               put "revdb" & return after tExternals
            end if
            put tExternal & return after tExternals
         else if tExternal is among the words of "revpdfprinter" then
            put tExternal & return after tDrivers
         else
            put tExternal & return after tExternals
         end if
      end if
   end repeat
   delete the last char of tExternals
   delete the last char of tDrivers
   
   -- Compute the stackfiles list
   lock messages
   local tStackFiles
   revSBRelativeStackFilesList pStack, tStackFiles
   unlock messages
   
   -- Make sure the app-bundle isn't already there
   if there is a file pAabFile then
      delete file pAabFile
      if there is a file pAabFile then
         throw "unable to remove existing aab"
      end if
   end if
   
   try
      ------- Create the build folder
      local tBuildFolder
      local tResBuildFolder, tClassesBuildFolder, tLibsBuildFolder
      local tDrawableResBuildFolder, tLayoutResBuildFolder, tXMLResBuildFolder, tValuesResBuildFolder
      put tempName() into tBuildFolder
      create folder tBuildFolder
      if the platform is "win32" then
         put shortFilePath(tBuildFolder) into tBuildFolder
      end if
      
      put tBuildFolder & slash & "classes_app" into tClassesBuildFolder
      put tBuildFolder & slash & "lib" into tLibsBuildFolder
      
      put tBuildFolder & slash & "res-build/res" into tResBuildFolder
      put tResBuildFolder & slash & "drawable" into tDrawableResBuildFolder
      put tResBuildFolder & slash & "layout" into tLayoutResBuildFolder
      put tResBuildFolder & slash & "xml" into tXMLResBuildFolder
      put tResBuildFolder & slash & "values" into tValuesResBuildFolder
      create folder tClassesBuildFolder
      create folder tLibsBuildFolder
      
      local tArchLibsBuildFolders
      repeat for each item tArch in tArchABIs
         put tLibsBuildFolder & slash & tArch into tArchLibsBuildFolders[tArch]
         create folder tArchLibsBuildFolders[tArch]
         if there is not folder tArchLibsBuildFolders[tArch] then
            throw "could not create build folders"
         end if
      end repeat
      
      revSBEnsureFolder tResBuildFolder
      if there is no folder tDrawableResBuildFolder then
         create folder tDrawableResBuildFolder
      end if
      if there is no folder tLayoutResBuildFolder then
         create folder tLayoutResBuildFolder
      end if
      if there is no folder tXMLResBuildFolder then
         create folder tXMLResBuildFolder
      end if
      if there is no folder tValuesResBuildFolder then
         create folder tValuesResBuildFolder
      end if
      if there is no folder tBuildFolder or \
            there is no folder tClassesBuildFolder or \
            there is no folder tLibsBuildFolder or \
            there is no folder tResBuildFolder or \
            there is no folder tDrawableResBuildFolder or \
            there is no folder tLayoutResBuildFolder or \
            there is no folder tXMLResBuildFolder or \
            there is no folder tValuesResBuildFolder then
         throw "could not create build folders"
      end if
      
      if the platform is "win32" then
         put shortFilePath(tBuildFolder) into tBuildFolder
      end if
      
      -------- Unpack all the files used by the externals
      local tManifestFile, tManifest
      
      revStandaloneProgress "Integrating externals..."
      
      if tExternals is not empty then
         put return after tExternals
      end if
      set the itemDelimiter to "."
      
      local tResolvedFileData
      revSBUpdateSettingsForExtensions "android", pSettings
      revSBResolveCopyFilesList tBaseFolder, "android", pSettings, tResolvedFileData
      
      repeat for each element tFile in tResolvedFileData
         -- Add to list of manifests to merge
         if tFile["name"] is "AndroidManifest.xml" then
            appendToStringList tFile["resolved"], pSettings["androidManifests"]
            next repeat
         end if
         
         local tExtJars
         put empty into tExtJars
         -- Only look for lcext files.
         switch the last item of tFile["name"]
            case "lcext"
               if there is no file tFile["resolved"] then
                  throw "could not find referenced external -" && tFile["resolved"]
               end if
               if addExternalFromFile(tFile["resolved"], tClassesBuildFolder, tArchLibsBuildFolders, tExtJars) then
                  -- Add the external to the list to load
                  put char 1 to -7 of tFile["name"] & return after tExternals
                  appendToStringList tExtJars, pSettings["jarFiles"]
               end if
               break
            case "lcextd"
               if there is no folder tFile["resolved"] then
                  throw "could not find referenced external -" && tFile["resolved"]
               end if
               if addExternalFromFolder(tFile["resolved"], tClassesBuildFolder, tArchLibsBuildFolders, tExtJars) then
                  -- Add the external to the list to load
                  put char 1 to -8 of tFile["name"] & return after tExternals
                  appendToStringList tExtJars, pSettings["jarFiles"]
               end if
               break
         end switch 
         
      end repeat
      delete the last char of tExternals
      set the itemDelimiter to comma
      
      -------- Resolve & fetch maven dependencies
      revStandaloneProgress "Fetching dependencies..."
      
      addAndroidDependenciesToSettings pSettings
      expandAARsAndComputeSettings tBuildFolder, pSettings
      
      -------- Create the Manifest
      revStandaloneProgress "Writing manifest..."
      
      if tManifestFile is empty then
         put tBuildFolder & slash & "AndroidManifest.xml" into tManifestFile
      end if
      
      if tManifest is empty then
         put url ("binfile:" & mapFilePath(revMobileRuntimeFolder(pTarget) & slash & "Manifest.xml")) into tManifest
      end if
      // SN-2015-01-22: [[ Bug 13213 ]] Throw an error in case an error occurred
      if the result is not empty then
         throw "Cannot find the template Manifest"
      end if
      local tEscapedLabel
      put escapeLabel(pSettings["android,label"]) into tEscapedLabel
      replace "${LABEL}" with textEncode(tEscapedLabel, "utf-8") in tManifest
      replace "${NAME}" with ".mblandroid" in tManifest
      replace "${IDENTIFIER}" with pSettings["android,identifier"] in tManifest
      replace "${VERSION_NAME}" with pSettings["android,version name"] in tManifest
      replace "${VERSION_CODE}" with pSettings["android,version code"] in tManifest
      
      /* Use legacy icon if adaptive icons are not provided */
      local tIsLegacyIcon
      put false into tIsLegacyIcon
      
      if pSettings["android,icon type"] is empty then
         put "legacy" into pSettings["android,icon type"]
      end if
      
      local tManifestIcon
      if pSettings["android,icon type"] is "adaptive" and \
            pSettings["android,adaptive icons resources path"] is not empty then
         put format("android:icon=\"@mipmap/ic_launcher\"") into tManifestIcon
               else if pSettings["android,icon type"] is "legacy" and \
               there is a file tIcon then
      put format("android:icon=\"@drawable/icon\"") into tManifestIcon
            put true into tIsLegacyIcon
   else
      put empty into tManifestIcon
   end if
   replace "${ICON}" with tManifestIcon in tManifest
   
   if pSettings["android,status bar hidden"] then
      replace "${THEME}" with "@android:style/Theme.NoTitleBar.Fullscreen" in tManifest
   else
      replace "${THEME}" with "@android:style/Theme.NoTitleBar" in tManifest
   end if
   
   local tAllowedAppIDs
   if pSettings["android,allowed app ids"] is not empty then
      put "<queries>" & return into tAllowedAppIDs
      repeat for each line tAppId in pSettings["android,allowed app ids"]
         put "<package android:name=" & quote & tAppId & quote && "/>" & return after tAllowedAppIDs
      end repeat
      put "</queries>" after tAllowedAppIDs
   end if
   replace "${QUERY_LIST}" with tAllowedAppIDs in tManifest
   
   local tInitialOrientation
   put pSettings["android,initial orientation"] into tInitialOrientation
   if tInitialOrientation is "landscape" then
      put "sensorLandscape" into tInitialOrientation
   end if
   replace "${ORIENTATION}" with tInitialOrientation in tManifest
   
   replace "${MIN_SDK_VERSION}" with pSettings["android,minimum version"] in tManifest
   replace "${TARGET_SDK_VERSION}" with targetSDKVersion() in tManifest
   
   local tUsesFeature, tUsesPermission, tFeatures, tPermissions, tAd
   repeat for each key tFeature in pSettings["android,device capabilities"]
      put "  <uses-feature android:name="&quote&"android."&tFeature&quote&" android:required="&quote&"${REQUIRED}"&quote&" />" into tUsesFeature
      replace "${REQUIRED}" with pSettings["android,device capabilities"][tFeature] in tUsesFeature
      put tUsesFeature & return after tFeatures
   end repeat
   repeat for each key tPermission in pSettings["android,capability permissions"]
      put "  <uses-permission android:name="&quote&"android.permission."&tPermission&quote&" />" into tUsesPermission
      put tUsesPermission & return after tPermissions
   end repeat
   repeat for each key tPermission in pSettings["android,application permissions"]
      if tPermission is "AD" then
         put true into tAd
         put "  <uses-permission android:name="&quote&"android.permission.ACCESS_NETWORK_STATE"&quote&"/>" & return into tUsesPermission
         put "  <uses-permission android:name="&quote&"android.permission.READ_PHONE_STATE"&quote&" />" after tUsesPermission
      else
         put "  <uses-permission android:name="&quote&"android.permission."&tPermission&quote&" />" into tUsesPermission
      end if
      put tUsesPermission & return after tPermissions
   end repeat
   
   replace "${USES_FEATURE}" with tFeatures in tManifest
   --replace "${USES_PERMISSION}" with tPermissions in tManifest
   
   local tService, tReceiver
   -- MW-2017-06-13: add generic service
   put "<service android:enabled=" & quote & "true" & quote && "android:name=" & quote & ".mblandroidservice" & quote & "/>" & return after tService
   
   -- IM-2012-02-28: need barebones receiver for local notifications
   put "<receiver android:name="&quote&"AppReceiver"&quote&">" into tReceiver
   --      if tBilling then
   --         -- create service & receiver sections for billing support
   --         put "<service android:name="&quote&"AppService"&quote&" />" into tService
   --         put "<intent-filter>" & return after tReceiver
   --         repeat for each item tMsgName in "IN_APP_NOTIFY,RESPONSE_CODE,PURCHASE_STATE_CHANGED"
   --            put "<action android:name="&quote&"com.android.vending.billing."&tMsgName&quote&" />" & return after tReceiver
   --         end repeat
   --         put "</intent-filter>" after tReceiver
   --      else
   --         put empty into tService
   --      end if
   put "</receiver>" after tReceiver
   
   local tProxyBillingActivity
   -- PM-2014-03-17: [[ In App Purchasing Updates ]] Include new store setting in manifest.
   if pSettings["android,inAppPurchasing"] then
      get pSettings["android,billingProvider"]
      if it is "Google" then
         put "  <uses-permission android:name="&quote&"com.android.vending.BILLING"&quote&" />" & return after tPermissions
         put "<activity" & CR & \
               "android:name=" & quote & "com.android.billingclient.api.ProxyBillingActivity" & quote & CR & \
               "android:configChanges=" & quote & "keyboard|keyboardHidden|screenLayout|screenSize|orientation" & quote & CR & \ 
               "android:theme=" & quote & "@android:style/Theme.Translucent.NoTitleBar" & quote & return & \
               "android:exported=" & quote & "false" & quote & " />" into tProxyBillingActivity
      end if
      if it is "Samsung" then
         put "  <uses-permission android:name="&quote&"com.sec.android.iap.permission.BILLING"&quote&" />" & return after tPermissions
      end if
      --if it is "Amazon" and revLicenseType() is "commercial" then
      if it is "Amazon" then
         --         local tAmazonReceiver
         --         put "<receiver android:name="&quote&"com.amazon.inapp.purchasing.ResponseReceiver" & quote & \
         --               " android:exported=" & quote & "true" & quote & ">" into tAmazonReceiver
         --         put "<intent-filter>" & return after tAmazonReceiver
         --         put "<action android:name="&quote&"com.amazon.inapp.purchasing.NOTIFY"&quote&" " & cr after tAmazonReceiver
         --         put "android:permission ="&quote&"com.amazon.inapp.purchasing.Permission.NOTIFY"&quote&"  />" & cr after tAmazonReceiver
         --         put "</intent-filter>" after tAmazonReceiver
         --         put "</receiver>" after tAmazonReceiver
         --         put tAmazonReceiver after tReceiver
         put AmazonBillingReceiver() after tReceiver
      end if
   end if
   
   replace "${BILLING_ACTIVITY}" with tProxyBillingActivity in tManifest
   
   local tNFCIntentFilter
   if pSettings["android,nfc"] then
      put "<intent-filter>" & return & \
            "<action android:name=" & quote & "android.nfc.action.TECH_DISCOVERED" & quote & " />" & cr & \
            "</intent-filter>" & return & \
            "<meta-data android:name=" & quote & "android.nfc.action.TECH_DISCOVERED" & quote & \
            " android:resource=" & quote & "@xml/nfc_tech_filter" & quote & " />" & cr into tNFCIntentFilter
      
      put "<uses-permission android:name=" & quote & "android.permission.NFC" & quote & " />" & cr after tPermissions
   end if
   replace "${NFC_FILTER}" with tNFCIntentFilter in tManifest
   
   replace "${SERVICE}" with tService in tManifest
   replace "${RECEIVER}" with tReceiver in tManifest
   replace "${USES_PERMISSION}" with tPermissions in tManifest
   
   if tAd is true then
      replace "${AD_ACTIVITY}" with "<activity android:name=" & quote & "com.inneractive.api.ads.InneractiveFullScreenView" & quote & "></activity>" in tManifest
   else
      replace "${AD_ACTIVITY}" with empty in tManifest
   end if
   
   local tInstallLocation
   switch pSettings["android,installLocation"]
      case "Internal Storage Only"
      case empty
         put empty into tInstallLocation
         break
      case "Allow External Storage"
         put "android:installLocation="&q("auto") into tInstallLocation
         break
      case "Prefer External Storage"
         put "android:installLocation="&q("preferExternal") into tInstallLocation
         break
   end switch
   replace "${INSTALL_LOCATION}" with tInstallLocation in tManifest
   
   local tCustomUrlFilter
   if pSettings["android,customUrlScheme"] is not empty then
      put "<intent-filter>" & \
            "<action android:name="&q("android.intent.action.VIEW")&" />" & \
            "<category android:name="&q("android.intent.category.DEFAULT")&" />" & \
            "<category android:name="&q("android.intent.category.BROWSABLE")&" />" & \
            "<data android:scheme="&q(pSettings["android,customUrlScheme"])&" />" & \
            "</intent-filter>" into tCustomUrlFilter
   else
      put empty into tCustomUrlFilter
   end if
   replace "${CUSTOM_URL_FILTER}" with tCustomUrlFilter in tManifest
   
   local tPushPermissions
   local tPushService
   if tUseFirebaseMessaging then
      put "<uses-permission android:name=" & q("android.permission.POST_NOTIFICATIONS") & \
            "/>" into tPushPermissions
      put "<service android:name=" & q("PushService") & \
            " android:exported=" & q("false") & ">" & \
            "<intent-filter>" & \
            "<action android:name="&q("com.google.firebase.MESSAGING_EVENT")&" />" & \
            "</intent-filter>" & \
            "</service>" into tPushService
   else
      put empty into tPushPermissions
      put empty into tPushService
   end if
   replace "${PUSH_PERMISSIONS}" with tPushPermissions in tManifest
   replace "${PUSH_SERVICE}" with tPushService in tManifest
   // Add the file provider to the manifest
   local tProvider
   put "<provider " & cr into tProvider
   put "      android:name=" & q(pSettings["android,identifier"] & ".AppProvider") & cr after tProvider
   put "      android:authorities=" & q(pSettings["android,identifier"] & ".fileprovider") & cr after tProvider
   put "      android:exported=" & q("false") & cr after tProvider
   put "      android:grantUriPermissions=" & q("true") & " >" & cr after tProvider
   // Add meta-data tag
   put "      <meta-data" & cr after tProvider
   put "            android:name=" & q("android.support.FILE_PROVIDER_PATHS") & cr after tProvider
   put "            android:resource=" & q("@xml/file_provider_paths") & " />" & cr after tProvider
   put "    </provider>" & cr after tProvider
   
   replace "${PROVIDER}" with tProvider in tManifest
   
   // SN-2015-09-24: [[ Bug 15875 ]] Add the screenSize configChanges value for API > 12
   //  Otherwise the app restarts on orientation change.
   local tConfigChangesProp
   put "keyboardHidden|orientation|uiMode|screenSize" into tConfigChangesProp
   replace "${CONFIG_CHANGES}" with tConfigChangesProp in tManifest
   
   // SN-2015-09-30: [[ Bug 10267 ]] Hardware Acceleration option added
   local tHardwareAccelerated
   if pSettings["android,hardware accelerated"] then
      put "true" into tHardwareAccelerated
   else
      put "false" into tHardwareAccelerated
   end if
   replace "${HARDWARE_ACCELERATED}" with tHardwareAccelerated in tManifest
   
   // Allow http connections
   local tAllowHttpConnections, tHasInternetPermission
   if the keys of pSettings["android,application permissions"] contains "Internet" then
      put "true" into tHasInternetPermission
   end if
   if pSettings["android,allow http"] and tHasInternetPermission then
      put "android:usesCleartextTraffic=" & q("true") into tAllowHttpConnections
   else
      put empty into tAllowHttpConnections
   end if
   replace "${ALLOW_HTTP_CONNECTIONS}" with tAllowHttpConnections in tManifest
   
   put tManifest into url ("binfile:" & tManifestFile)
   
   local tAdditional
   repeat for each line tManifest in pSettings["androidManifests"]
      appendToList tManifest, tAdditional
   end repeat
   local tBuildVariables
   put pSettings["android,identifier"] into tBuildVariables["applicationId"]
   put androidCreateAppManifest(tManifestFile, tAdditional, tBuildVariables) \
         into url ("binfile:" & tManifestFile)
   if the result is not empty then
      throw "could not create manifest"
   end if
   
   -------- Build the Classes
   revStandaloneProgress "Building classes..."
   
   -- MW-2012-07-05: Make sure we record all classes we build so we can clean up.
   local tCompiledClassFilePath, tBuiltClassFiles
   put empty into tBuiltClassFiles
   put pSettings["android,identifier"] into tCompiledClassFilePath
   replace "." with "/" in tCompiledClassFilePath
   
   local tLiveCodeClassesFile
   put tBuildFolder & slash & "LiveCode.jar" into tLiveCodeClassesFile
   put url ("binfile:" & mapFilePath(revMobileRuntimeFolder(pTarget) & slash & "Classes")) into url ("binfile:" & tLiveCodeClassesFile)
   if the result is not empty then
      throw "could not prepare LiveCode classes"
   end if
   
   local tClassPath
   if the platform is "win32" then
      put pathToRootClasses() & ";" & tLiveCodeClassesFile & ";" & tClassesBuildFolder & ";" into tClassPath
   else
      put pathToRootClasses() & ":" & tLiveCodeClassesFile & ":" & tClassesBuildFolder into tClassPath
   end if
   
   -- MW-2017-06-13: compile the renamed service class
   local tClass, tClassFile
   put tClassesBuildFolder & slash & "mblandroidservice.java" into tClassFile
   put "package" && pSettings["android,identifier"] & ";" & cr into tClass
   put "import com.runrev.android.LiveCodeService;" & cr after tClass
   put "public class mblandroidservice extends LiveCodeService {}" & cr after tClass
   put tClass into url ("binfile:" & tClassFile)
   if the result is not empty then
      throw "could not create billing support class"
   end if
   appendToStringList tClassFile, tBuiltClassFiles
   executeShellCommand pathToJavaC(), "-target 1.5 -source 1.5 -Xlint:none -d", tClassesBuildFolder, "-cp", tClassPath, tClassFile
   if the result is not empty then
      throw "could not compile service support class"
   end if
   appendToStringList tClassesBuildFolder & slash & tCompiledClassFilePath & "/mblandroidservice.class", tBuiltClassFiles
   
   put tClassesBuildFolder & slash & "mblandroid.java" into tClassFile
   put "package" && pSettings["android,identifier"] & ";" & cr into tClass
   put "import com.runrev.android.LiveCodeActivity; import java.lang.reflect.*;" & cr after tClass
   put "public class mblandroid extends LiveCodeActivity {public Class getServiceClass() {return mblandroidservice.class;}}" & cr after tClass
   put tClass into url ("binfile:" & tClassFile)
   if the result is not empty then
      throw "could not create activity class"
   end if
   appendToStringList tClassFile, tBuiltClassFiles
   executeShellCommand pathToJavaC(), "-target 1.5 -source 1.5 -Xlint:none -d", tClassesBuildFolder, "-cp", tClassPath, tClassFile
   if the result is not empty then
      throw "could not compile application class"
   end if
   appendToStringList tClassesBuildFolder & slash & tCompiledClassFilePath & "/mblandroid.class", tBuiltClassFiles
   
   -- IM-2012-02-28: need barebones receiver for local notifications
   // build receiver class
   put tClassesBuildFolder & slash & "AppReceiver.java" into tClassFile
   put "package" && pSettings["android,identifier"] & ";" & cr into tClass
   put "import com.runrev.android.EngineReceiver;" & cr after tClass
   put "public class AppReceiver extends EngineReceiver {}" & cr after tClass
   put tClass into url ("binfile:" & tClassFile)
   if the result is not empty then
      throw "could not create billing support class"
   end if
   appendToStringList tClassFile, tBuiltClassFiles
   
   executeShellCommand pathToJavaC(), "-target 1.5 -source 1.5 -Xlint:none -d", tClassesBuildFolder, "-cp", tClassPath, tClassFile
   if the result is not empty then
      throw "could not compile billing support class"
   end if
   appendToStringList tClassesBuildFolder & slash & tCompiledClassFilePath & "/AppReceiver.class", tBuiltClassFiles
   
   -- IM-2011-10-26: Generate and compile billing service & receiver classes
   --      if tBilling then
   --         local tBillingClass, tBillingClassFile
   
   --         // build service class
   --         put tClassesBuildFolder & slash & "AppService.java" into tBillingClassFile
   --         put "package" && pSettings["android,identifier"] & ";" & return into tBillingClass
   --         put "import com.runrev.android.billing.BillingService;" & return after tBillingClass
   --         put "public class AppService extends BillingService {}" & return after tBillingClass
   --         put tBillingClass into url ("binfile:" & tBillingClassFile)
   --         if the result is not empty then
   --            throw "could not create billing support class"
   --         end if
   --         appendToStringList tBillingClassFile, tBuiltClassFiles
   
   --         executeShellCommand pathToJavaC(), "-target 1.5 -source 1.5 -Xlint:none -d", tClassesBuildFolder, "-cp", tClassPath, tBillingClassFile
   --         if the result is not empty then
   --            throw "could not compile billing support class"
   --         end if
   --         appendToStringList tClassesBuildFolder & slash & tCompiledClassFilePath & "/AppService.class", tBuiltClassFiles
   --      end if
   
   // Generate push notification service class
   if tUseFirebaseMessaging then
      local tPushServiceClass, tPushServiceClassFile
      put tClassesBuildFolder & slash & "PushService.java" into tPushServiceClassFile
      
      put "package "&pSettings["android,identifier"]&";" & cr & \
            "import com.runrev.android.*;" & cr & \
            "public class PushService extends com.runrev.android.LiveCodeFirebaseMessagingService {}" & cr into tPushServiceClass
      
      put tPushServiceClass into url ("binfile:" & tPushServiceClassFile)
      if the result is not empty then
         throw "could not create push notification support class"
      end if
      appendToStringList tPushServiceClassFile, tBuiltClassFiles
      
      local tCombinedClassPath
      put tClassPath into tCombinedClassPath
      repeat for each line tJar in pSettings["jarFiles"]
         if the platform is "win32" then
            put ";" & tJar after tCombinedClassPath
         else
            put ":" & tJar after tCombinedClassPath
         end if
      end repeat
      
      executeShellCommand pathToJavac(), "-target 1.5 -source 1.5 -Xlint:none -d", tClassesBuildFolder, "-cp", tCombinedClassPath, tPushServiceClassFile
      put the result into tResult
      if tResult is not empty then
         throw "error compiling push notification service class:" & cr & tResult
      end if
      appendToStringList tClassesBuildFolder & slash & tCompiledClassFilePath & "/PushService.class", tBuiltClassFiles
   end if
   
   // Generate Google services resources
   if tUseGoogleServices then
      local tGoogleServicesJSON
      put pSettings["android,googleServicesJSON"] into tGoogleServicesJSON
      if pathIsRelative(tGoogleServicesJSON) then
         put tBaseFolder & slash before tGoogleServicesJSON
      end if
      if there is a file tGoogleServicesJSON then
         local tGoogleServicesResources, tGoogleServicesResourceXML
         put getGoogleServicesStringResources(pSettings["android,identifier"], url ("file:" & tGoogleServicesJSON)) into tGoogleServicesResources
         if tGoogleServicesResources is empty then
            throw "Could not read configuration for app " & quote&pSettings["android,identifier"]&quote & " from the Google services JSON file."
         end if
         put generateStringResourceXML(tGoogleServicesResources) into tGoogleServicesResourceXML
         put tGoogleServicesResourceXML into url ("file:"&tValuesResBuildFolder&slash&"google-services.xml")
      else
         throw "An enabled feature requires Google Services to be configured. Please specify the path to your google-services.json file in the Standalone Application Settings for Android"
      end if
   end if
   
   // Generate app content provider class
   local tProviderClass, tProviderClassFile
   put tClassesBuildFolder & slash & "AppProvider.java" into tProviderClassFile
   
   put "package" && pSettings["android,identifier"] & ";" & return into tProviderClass
   put "import com.runrev.android.*;" & cr after tProviderClass
   put "public class AppProvider extends com.runrev.android.AppProvider {}" & return after tProviderClass
   
   put tProviderClass into url ("binfile:" & tProviderClassFile)
   if the result is not empty then
      throw "could not create app content provider"
   end if
   appendToStringList tProviderClassFile, tBuiltClassFiles
   
   executeShellCommand pathToJavac(), "-target 1.5 -source 1.5 -Xlint:none -d", tClassesBuildFolder, "-cp", tClassPath, tProviderClassFile
   if the result is not empty then
      throw "could not compile app content provider" & cr & the result
   end if
   appendToStringList tClassesBuildFolder & slash & tCompiledClassFilePath & "/AppProvider.class", tBuiltClassFiles
   
   -- MW-2012-07-05: Record all asset files that are copied into /tmp
   local tAssetFiles
   put empty into tAssetFiles
   
   local tAssetArchive
   put tBuildFolder & slash & "lcandroid.ap_" into tAssetArchive
   if there is a file tAssetArchive then
      delete file tAssetArchive
   end if
   
   local tLayoutXML
   put mapFilePath(revMobileRuntimeFolder(pTarget) & slash & "livecode_inputcontrol.xml") into tLayoutXML
   put url ("binfile:" & tLayoutXML) into url ("binfile:" & tLayoutResBuildFolder & slash & "livecode_inputcontrol.xml")
   if the result is not empty then
      throw "could not copy layout file '" & tLayoutXML & "'"
   end if
   put tLayoutResBuildFolder & slash & "livecode_inputcontrol.xml" & cr after tAssetFiles
   
   local tNFCTechFilter
   put mapFilePath(revMobileRuntimeFolder(pTarget) & slash & "nfc_tech_filter.xml") into tNFCTechFilter
   put url ("binfile:" & tNFCTechFilter) into url ("binfile:" & tXMLResBuildFolder & slash & "nfc_tech_filter.xml")
   if the result is not empty then
      throw "could not copy NFC tech filter file '" & tNFCTechFilter & "'"
   end if
   put tXMLResBuildFolder & slash & "nfc_tech_filter.xml" & cr after tAssetFiles
   
   /* Adaptive Icons */
   if pSettings["android,icon type"] is "adaptive" and \
         pSettings["android,adaptive icons resources path"] is not empty then
      local tAdaptiveIconsResFolder 
      put pSettings["android,adaptive icons resources path"] \
            into tAdaptiveIconsResFolder
      if pathIsRelative(tAdaptiveIconsResFolder) then
         put tBaseFolder & slash before tAdaptiveIconsResFolder
      end if
      
      local tAdaptiveIconsResSubfolders
      put folders(tAdaptiveIconsResFolder) into tAdaptiveIconsResSubfolders
      repeat for each line tResSubfolder in tAdaptiveIconsResSubfolders
         if tResSubfolder is ".." or tResSubfolder is "layout" then
            next repeat
         end if
         
         local tSubfolderContents
         put files(tAdaptiveIconsResFolder & slash & tResSubfolder) \
               into tSubfolderContents
         
         if there is not a folder (tResBuildFolder & slash & tResSubfolder) then
            revSBEnsureFolder tResBuildFolder & slash & tResSubfolder
            filter lines of tSubfolderContents without "*.webp"
         end if
         
         repeat for each line tFile in tSubfolderContents
            revCopyFile \
                  tAdaptiveIconsResFolder & slash & tResSubfolder & slash & tFile, \
                  tResBuildFolder & slash & tResSubfolder
         end repeat
      end repeat
      
      /* Inclusion of res/values(-night)/themes.xml causes a build error so remove it */
      local tThemesXml
      
      put tResBuildFolder & slash & "values/themes.xml" into tThemesXml
      if there is a file tThemesXml then
         delete file tThemesXml
      end if
      
      put tResBuildFolder & slash & "values-night/themes.xml" into tThemesXml
      if there is a file tThemesXml then
         delete file tThemesXml
      end if
      
      /* Inclusion of res/values(-night)/styles.xml causes a build error so remove it */
      local tStylesXml
      put tResBuildFolder & slash & "values/styles.xml" into tStylesXml
      if there is a file tStylesXml then
         delete file tStylesXml
      end if
      
      put tResBuildFolder & slash & "values-night/styles.xml" into tStylesXml
      if there is a file tStylesXml then
         delete file tStylesXml
      end if
   end if
   
   local tFileProviderPaths
   put mapFilePath(revMobileRuntimeFolder(pTarget) & slash & "file_provider_paths.xml") into tFileProviderPaths
   put url ("binfile:" & tFileProviderPaths) into url ("binfile:" & tXMLResBuildFolder & slash & "file_provider_paths.xml")
   if the result is not empty then
      throw "could not copy file provider paths file '" & tFileProviderPaths & "'"
   end if
   put tXMLResBuildFolder & slash & "file_provider_paths.xml" & return after tAssetFiles
   
   /* Use legacy icon if adaptive icons are not provided */
   if tIsLegacyIcon then
      put url ("binfile:" & tIcon) into url ("binfile:" & tDrawableResBuildFolder & slash & "icon.png")
      if the result is not empty then
         throw "could not copy icon '" & tIcon & "'"
      end if
      put tDrawableResBuildFolder & slash & "icon.png" & cr after tAssetFiles
   end if
   
   if there is a file tStatusBarIcon then
      put url ("binfile:" & tStatusBarIcon) into url ("binfile:" & tDrawableResBuildFolder & slash & "notify_icon.png")
      if the result is not empty then
         throw "could not copy icon '" & tStatusBarIcon & "'"
      end if
      put tDrawableResBuildFolder & slash & "notify_icon.png" & cr after tAssetFiles
   end if
   
   ------- Compile the Standalone
   revStandaloneProgress "Building executable..."
   
   put tExternals into pSettings["externals"]
   
   appendToStringList "revsecurity:./librevsecurity", pSettings["android,library"]
   repeat for each line tEntry in tExternals
      appendToStringList tEntry & ":" & "./lib" & tEntry, pSettings["android,library"]
   end repeat
   repeat for each line tEntry in tDrivers
      appendToStringList tEntry & ":" & "./lib" & tEntry, pSettings["android,library"]
   end repeat
   
   set the itemDelimiter to comma
   repeat for each item tArch in tArchs
      local tArchCodeResources
      filter pSettings["extension_code_resources"] \
            with ("*code/" & tArch & "-android*") into tArchCodeResources
      
      repeat for each line tLib in tArchCodeResources
         local tSourceFile, tSourceName
         set the itemdelimiter to slash
         put item -1 of tLib into tSourceFile
         set the itemDelimiter to "."
         put item 1 to -2 of tSourceFile into tSourceName
         set the itemDelimiter to comma
         
         if not(tSourceFile begins with "lib") then
            put "lib" before tSourceFile
         end if
         
         put url ("binfile:" & tLib) into \
               url ("binfile:" & tArchLibsBuildFolders[__ArchABI(tArch)] & slash & tSourceFile)
         
         if (tSourceName & ":./" & tSourceFile) is not among the lines of pSettings["android,library"] then
            appendToStringList tSourceName & ":./" & tSourceFile, pSettings["android,library"]
         end if
      end repeat
   end repeat
   
   local tDeploy
   -- Update the deploy params with script library and extension inclusions
   revSBUpdateDeployParams pStack, "android", pSettings, tDeploy
   
   -- Stackfile to use
   put the effective filename of stack pStack into tDeploy["stackfile"]
   
   repeat for each key tArch in tArchLibsBuildFolders
      -- Engine to use
      put mapAndroidPath(tArch) & slash & "Standalone" into tDeploy["engine"]
      // SN-2015-01-22: [[ Bug 13213 ]] Throw an error in case an error occurred
      if there is no file tDeploy["engine"] then
         throw "Could not find standalone engine"
      end if
      
      -- Output file to create
      put tArchLibsBuildFolders[tArch] & slash & "librevandroid.so" into tDeploy["output"]
      
      _internal deploy android tDeploy
      if the result is not empty then
         throw the result
      end if
   end repeat
   
   -------- Assembling Resources
   revStandaloneProgress "Assembling resources..."
   
   local tLibPackages
   if pSettings["libraryPackages"] is not empty then
      put pSettings["libraryPackages"] into tLibPackages
      replace cr with ":" in tLibPackages
   end if
   
   local tResourceClasses, tCompiledResourceClasses
   local tResourceGenFolder, tClassesFile
   put tBuildFolder & slash & "gen" into tResourceGenFolder
   revSBEnsureFolder tResourceGenFolder
   
   compileResourceClasses \
         tBuildFolder, \
         tResBuildFolder, \
         pSettings, \
         tCompiledResourceClasses
   if the result is not empty then
      throw format( \
            "could not compile resource classes - error:\n%s", \
            the result)
   end if
   
   linkResources \
         tBuildFolder, \
         tResourceGenFolder, \
         tManifestFile, \
         tCompiledResourceClasses, \
         tLibPackages, \
         tResourceClasses
   if the result is not empty then
      throw "could not link resources - error:" & cr & the result
   end if
   put tBuildFolder into tClassesFile
   
   repeat for each line tLine in revSBEnumerateFolder(tResourceGenFolder)
      if tLine ends with "/R.java" then
         appendToStringList tResourceGenFolder & slash & tLine, tResourceClasses
      end if
   end repeat
   if tResourceClasses is not empty then
      local tResourceCompileParams
      appendToParams tResourceCompileParams, "-target", "1.5", "-source", "1.5", "-Xlint:none"
      appendToParams tResourceCompileParams, "-d", tResourceGenFolder
      appendToParams tResourceCompileParams, "-cp", tClassPath
      repeat for each line tRClass in tResourceClasses
         appendToParams tResourceCompileParams, tRClass
      end repeat
      executeShellCommandWithParams pathToJavac(), tResourceCompileParams
      if the result is not empty then
         throw "could not compile resource class" & return & the result
      end if
      repeat for each line tLine in revSBEnumerateFolder(tResourceGenFolder)
         if tLine ends with ".class" then
            appendToStringList tResourceGenFolder & slash & tLine, tBuiltClassFiles
         end if
      end repeat
   end if
   
   // To avoid hitting command-line character limits, we write the list of input files to disk
   local tD8InputList
   appendToStringList tLiveCodeClassesFile, tD8InputList
   repeat for each line tJarFile in pSettings["jarFiles"]
      appendToStringList tJarFile, tD8InputList
   end repeat
   repeat for each line tClassFile in tBuiltClassFiles
      if tClassFile ends with ".class" then
         appendToStringList tClassFile, tD8InputList
      end if
   end repeat
   
   local tD8InputListParamFile
   put tBuildFolder & slash & "d8-input-list.txt" into tD8InputListParamFile
   put tD8InputList into url ("file:" & tD8InputListParamFile)
   if the result is not empty then
      throw "could not create list of encoded classes"
   end if
   
   local tD8Params
   appendToParams tD8Params, "--min-api", pSettings["android,minimum version"]
   appendToParams tD8Params, "--lib", pathToRootClasses()
   appendToParams tD8Params, "--output", tClassesFile
   appendToParams tD8Params, "@" & tD8InputListParamFile
   executeShellCommandWithParams pathToD8(), tD8Params
   put the result into tResult
   processD8Result tResult
   if tResult is not empty then
      throw "could not encode class bundle - error:" & cr & tResult
   end if
   
   -------- Assembling Assets
   revStandaloneProgress "Assembling assets..."
   
   revZipOpenArchive tAssetArchive, "update"
   if the result is not empty then
      throw "could not open asset archive"
   end if
   
   addAssetsToArchive tResolvedFileData, tBaseFolder, tAssetArchive
   
   revZipCloseArchive tAssetArchive
   if the result is not empty then
      throw "asset archive creation failed"
   end if
   
   ------- Prepare the Package
   revStandaloneProgress "Preparing package..."
   
   local tUnalignedApkFile
   put tBuildFolder & slash & "lcandroid-unaligned.apk" into tUnalignedApkFile
   if there is a file tUnalignedApkFile then
      delete file tUnalignedApkFile
   end if
   
   repeat for each key tArch in tArchLibsBuildFolders
      -- MM-2014-01-29: [[ OpenSSL ]] Include the revsecurity library.
      if pSettings["android,include revsecurity"] then
         put url ("binfile:" & mapFilePath(revMobileRuntimeFolder(pTarget) & slash & tArch & slash & "revsecurity")) \
               into url ("binfile:" & tArchLibsBuildFolders[tArch] & slash & "librevsecurity.so")
         
         // SN-2015-01-22: [[ Bug 13213 ]] Throw an error in case an error occurred
         if the result is not empty then
            throw "Could not find revsecurity library"
         end if
      end if
      
      -- Copy across the externals into the libs folder
      repeat for each line tEntry in tExternals
         -- Only copy across an external from the Runtime folder if we haven't
         -- already copied from a lcext.
         if there is a file (tArchLibsBuildFolders[tArch] & slash & "lib" & tEntry & ".so") then
            next repeat
         end if
         put url ("binfile:" & mapFilePath(revMobileRuntimeFolder(pTarget) & slash & tArch & slash & tEntry)) \
               into url ("binfile:" & tArchLibsBuildFolders[tArch] & slash & "lib" & tEntry & ".so")
         // SN-2015-01-22: [[ Bug 13213 ]] Throw an error in case an error occurred
         if the result is not empty then
            throw "Could not find " & tEntry && "library"
         end if
      end repeat
      
      -- Copy across any other driver libraries into the libs folder
      repeat for each line tEntry in tDrivers
         -- Only copy across the library if it's not already there
         if there is a file (tArchLibsBuildFolders[tArch] & slash & "lib" & tEntry & ".so") then
            next repeat
         end if
         put url ("binfile:" & mapFilePath(revMobileRuntimeFolder(pTarget) & slash & tArch & slash & tEntry)) \
               into url ("binfile:" & tArchLibsBuildFolders[tArch] & slash & "lib" & tEntry & ".so")
         if the result is not empty then
            throw "Could not find " & tEntry && "library"
         end if
      end repeat
   end repeat
   
   prepareBundle tBuildFolder, tArchLibsBuildFolders, tAssetArchive
   
   local tKeyStoreAlias, tKeyStorePassword, tPrivateKeyPassword
   if (tKey is not empty) or tUseDebugKey then
      if tUseDebugKey then
         put pathToDebugKey() into tKey
         put "androiddebugkey" into tKeyStoreAlias
         put "android" into tKeyStorePassword
         put "android" into tPrivateKeyPassword
         
         // Create debug key if it does not already exist
         if there is not a file tKey then
            local tKeytoolParams
            appendToParams tKeytoolParams, "-genkey"
            appendToParams tKeytoolParams, "-keystore", tKey
            appendToParams tKeytoolParams, "-storepass", tKeyStorePassword
            appendToParams tKeytoolParams, "-alias", tKeyStoreAlias
            appendToParams tKeytoolParams, "-keypass", tPrivateKeyPassword
            appendToParams tKeyToolParams, "-keyalg", "RSA"
            appendToParams tKeyToolParams, "-keysize", 2048
            appendToParams tKeyToolParams, "-validity", 10000
            appendToParams tKeytoolParams, "-dname", "CN=Android Debug,O=Android,C=US"
            
            executeShellCommandWithParams pathToKeytool(), tKeytoolParams
            put the result into tResult
            processKeytoolResult tResult
            if tResult is not empty then
               throw "Could not create debug key - error:" && tResult
            end if
         end if
      else
         if not tKey begins with "/" then
            put tBaseFolder & slash before tKey
         end if
         
         if there is no file tKey then
            throw "could not file keystore '" & tKey & "'"
         end if
         
         ask "Please provide the keystore alias to use"
         if it is empty then
            throw "no keystore alias provided for keystore"
         end if
         put it into tKeystoreAlias
         
         ask password clear "Please provide the keystore password"
         if it is empty then
            throw "no password provided for keystore"
         end if
         put it into tKeystorePassword
         
         ask password clear "Please provide the private key password"
         if it is empty then
            throw "no password provided for private key"
         end if
         put it into tPrivateKeyPassword
      end if
   end if
   
   generateBundle \
         tBuildFolder, \
         pAabFile, \
         tKey, \
         tKeystoreAlias, \
         tKeystorePassword, \
         tPrivateKeyPassword, \
         pDevice
   
   ------- Signing the Package
   if not (pTarget contains "test") then
      revStandaloneProgress "Signing package..."
      
      executeShellCommand \
            pathToJarSigner(), \
            "-sigalg", "SHA1withRSA", \
            "-digestalg", "SHA1", \
            "-keystore", tKey, \
            "-storepass", tKeystorePassword, \
            "-keypass", tPrivateKeyPassword, \
            pAabFile, \
            tKeystoreAlias
      
      if the result begins with "jarsigner error" then
         throw "signing failed -" && word 4 to -1 of the result
      else if the result begins with "jarsigner: Certificate chain not found" then
         throw "signing failed -" && word 2 to -1 of the result
      else if (the result begins with "jarsigner: key associated with") and (line 1 of the result ends with "not a private key") then
         throw "signing failed - key password was incorrect or" && word 2 to -1 of the result
      end if
   end if
   
catch tError
end try

if there is a file tUnalignedApkFile then delete file tUnalignedApkFile
if there is a file tAssetArchive then delete file tAssetArchive
if there is a file tLiveCodeClassesFile then delete file tLiveCodeClassesFile

repeat for each element tFolder in tArchLibsBuildFolders
   repeat for each line tFile in files(tFolder)
      delete file (tFolder & slash & tFile)
   end repeat
   if there is a folder tFolder then delete folder tFolder
end repeat

set the itemDelimiter to slash
repeat for each line tJarFile in pSettings["jarFiles"]
   if there is a file (tLibsBuildFolder & slash & item -1 of tJarFile) then 
      delete file (tLibsBuildFolder & slash & item -1 of tJarFile)
   end if
end repeat
if there is a folder tLibsBuildFolder then delete folder tLibsBuildFolder
if there is a file tClassesFile then delete file tClassesFile
repeat for each line tClassFile in tBuiltClassFiles
   if there is a file tClassFile then delete file tClassFile
end repeat
repeat while there is a folder (tClassesBuildFolder & slash & tCompiledClassFilePath)
   delete folder (tClassesBuildFolder & slash & tCompiledClassFilePath)
   if the result is not empty then
      exit repeat
   end if
   delete the last item of tCompiledClassFilePath
end repeat
set the itemDelimiter to comma

cleanTempFiles tAssetFiles, tManifestFile
cleanTempFolders tLayoutResBuildFolder, tDrawableResBuildFolder, tResBuildFolder, tClassesBuildFolder, tBuildFolder

--repeat for each line tFIle in tAssetFiles
--   if there is a file tFile then delete file tFile
--end repeat
--if there is a folder tLayoutResBuildFolder then
--   delete folder tLayoutResBuildFolder
--end if
--if there is a folder tDrawableResBuildFolder then
--   delete folder tDrawableResBuildFolder
--end if
--if there is a folder tResBuildFolder then
--   delete folder tResBuildFolder
--end if
--if there is a file tManifestFile then
--   delete file tManifestFile
--end if
--if there is a folder tClassesBuildFolder then
--   delete folder tClassesBuildFolder
--end if
--if there is a folder tBuildFolder then
--   delete folder tBuildFolder
--end if

if tError is not empty then
   throw tError
end if
end saveAsMobileStandaloneMain

private command cleanTempFiles pAssetFiles, pManifestFile
   repeat for each line tFIle in pAssetFiles
      if there is a file tFile then delete file tFile
   end repeat
   if there is a file pManifestFile then
      delete file pManifestFile
   end if
end cleanTempFiles

private command cleanTempFolders pLayoutResBuildFolder, pDrawableResBuildFolder, pResBuildFolder, pClassesBuildFolder, pBuildFolder
   if there is a folder pLayoutResBuildFolder then
      delete folder pLayoutResBuildFolder
   end if
   if there is a folder pDrawableResBuildFolder then
      delete folder pDrawableResBuildFolder
   end if
   if there is a folder pResBuildFolder then
      delete folder pResBuildFolder
   end if
   if there is a folder pClassesBuildFolder then
      delete folder pClassesBuildFolder
   end if
   if there is a folder pBuildFolder then
      delete folder pBuildFolder
   end if
end cleanTempFolders

################################################################################

private function escapeLabel pLabel
   replace "&" with "&amp;" in pLabel
   replace "@" with "\@" in pLabel
   replace "?" with "\?" in pLabel
   replace "<" with "&lt;" in pLabel
   replace ">" with "&gt;" in pLabel
   replace "'" with "\'" in pLabel
   replace quote with "\" & quote in pLabel
   return pLabel
end escapeLabel
   
private command processAaptResult @xResult   
   -- MW-2012-07-04: On Linux, 'aapt' can complain about libz version info
   --   so we delete that line from the result before checking for an error.
   if line 1 of xResult contains "no version information available" then
      delete line 1 of xResult
   end if
   // SN-2014-10-27: [[ Bug 13800 ]] libpng 1.6+ raises a warning for the PNG files having embedded sRGB profile
   if line 1 of xResult contains "iCCP: Not recognizing known sRGB profile that has been edited" then
      delete line 1 of xResult
   end if
end processAaptResult

private command processD8Result @xResult
   local tLineIndex = 1
   repeat while tLineIndex <= the number of lines in xResult
      local tLine
      put line tLineIndex of xResult into tLine
      if tLine begins with "Warning in " then
         // Warnings are spread over two lines - the filename, then the warning message
         local tWarning
         put "d8: " & tLine & " : " & line tLineIndex + 1 of xResult into tWarning
         delete line tLineIndex to tLineIndex + 1 of xResult
         if tWarning contains "desugaring" then
            // Ignore desugaring warnings for engine classes
         else
            revStandaloneAddWarning tWarning
         end if
      else if tLine begins with "Info:" then
         // Ignore Info messages from d8
         local tInfo, tInfoIndex
         put "d8: " & tLine into tInfo
         put tLineIndex into tInfoIndex
         repeat while (tInfoIndex < the number of lines in xResult) and \
               (line tInfoIndex + 1 of xResult begins with "Info in ")
            add 1 to tInfoIndex
            put " : " & line tInfoIndex of xResult after tInfo
            repeat while (tInfoIndex < the number of lines in xResult) and \
                  (line tInfoIndex + 1 of xResult begins with "  ")
               add 1 to tInfoIndex
               put " : " & line tInfoIndex of xResult after tInfo
            end repeat
         end repeat
         delete line tLineIndex to tInfoIndex of xResult
         // revStandaloneAddWarning tInfo
      else
         add 1 to tLineIndex
      end if
   end repeat
end processD8Result

private command processKeytoolResult @xResult
   local tLineIndex = 1
   repeat while tLineIndex <= the number of lines in xResult
      local tLine
      put line tLineIndex of xResult into tLine
      if tLine is empty then
         delete line tLineIndex of xResult
      else if tLine begins with "Warning:" then
         // Warnings are spread over two lines
         local tWarning
         put "keytool: " & tLine & " : " & line tLineIndex + 1 of xResult into tWarning
         delete line tLineIndex to tLineIndex + 1 of xResult
         if tWarning contains "The JKS keystore uses a proprietary format" then
            // Ignore warnings about proprietary keystore format
         else
            revStandaloneAddWarning tWarning
         end if
      else
         add 1 to tLineIndex
      end if
   end repeat
end processKeytoolResult

private command compileResourceClasses pBuildFolder, pResBuildFolder, @xSettings, @rCompiledResources
   local tAaptResult, tManifest, tCompiledResArchive
   repeat with x = 1 to the number of lines in xSettings["aarFiles"]
      local tResFolder
      put pBuildFolder & slash & x & "/res" into tResFolder
      if there is a folder tResFolder then
         put pBuildFolder & "/" & x & "/compiled_resources.zip" into tCompiledResArchive
         executeShellCommand pathToAapt2(), "compile", "--dir", tResFolder, \
            "-o", tCompiledResArchive
         put the result into tAaptResult
         processAaptResult tAaptResult
         if tAaptResult is not empty then
            return tAaptResult
         end if

         put "-R" && quote & tCompiledResArchive & quote & space after rCompiledResources
      end if
   end repeat

   if there is a folder pResBuildFolder then
      put pBuildFolder & "/compiled_resources.zip" into tCompiledResArchive
      executeShellCommand pathToAapt2(), "compile", "--dir", pResBuildFolder, \
         "-o", tCompiledResArchive
      put the result into tAaptResult
      processAaptResult tAaptResult
      if tAaptResult is not empty then
         return tAaptResult
      end if

      put "-R" && quote & tCompiledResArchive & quote & space after rCompiledResources
   end if

   delete the last codeunit of rCompiledResources
   return empty
end compileResourceClasses

private command linkResources pBuildFolder, pResourceGenFolder, pManifestFile, pCompiledResources, pLibPackages, @rResourceClassList

   local tBundleFile, tSrcFolder
   put pBuildFolder & slash & "aab-bundle.zip" into tBundleFile
   local tAapt2Params
   appendToParams tAapt2Params, "link"
   appendToParams tAapt2Params, "--proto-format"
   appendToParams tAapt2Params, "--auto-add-overlay"

   if pLibPackages is not empty then
      appendToParams tAapt2Params, "--extra-packages", pLibPackages
   end if

   appendToParams tAapt2Params, "-o", tBundleFile
   appendToParams tAapt2Params, "--java", pResourceGenFolder
   appendToParams tAapt2Params, "--manifest", pManifestFile
   appendToParams tAapt2Params, "-I", pathToRootClasses()
   appendToParams tAapt2Params, pCompiledResources

   local tAaptResult
   executeShellCommandWithParams pathToAapt2(), tAapt2Params

   put the result into tAaptResult
   processAaptResult tAaptResult
   if tAaptResult is not empty then
      return tAaptResult
   end if
   
   local tBundleDir
   put pBuildFolder & slash & "aab-bundle" & slash into tBundleDir
   revSBEnsureFolder tBundleDir
   
   // Open the app bundle archive and extract them into the app bundle directory
   set the itemDel to slash
   revZipOpenArchive tBundleFile, "read"
   if the result is empty then
      local tZipItems
      put revZipEnumerateItems(tBundleFile) into tZipItems
      local tFolder
      repeat for each line tZipItem in tZipItems
         put item 1 to -2 of tZipItem into tFolder
         revSBEnsureFolder (tBundleDir & slash & tFolder)
         revZipExtractItemToFile tBundleFile, tZipItem, (tBundleDir & slash & tZipItem)
      end repeat
      revZipCloseArchive tBundleFile
   end if
   
   return empty
end linkResources

private command prepareBundle pBuildFolder, pArchLibsBuildFolders, pAssetArchive
   local tBundleDir
   put pBuildFolder & slash & "aab-bundle" into tBundleDir

   // Move created manifest file into correct location for bundle
   local tManifestFile, tManifestDir
   put tBundleDir & slash & "AndroidManifest.xml" into tManifestFile
   put tBundleDir & slash & "manifest" into tManifestDir
   revSBEnsureFolder tManifestDir
   revSBCopyFileToFolder tManifestFile, tManifestDir
   if there is a file tManifestFile then delete file tManifestFile

   // Copy classes into bundle
   local tClassesFile, tClassesDir
   put pBuildFolder & slash & "classes.dex" into tClassesFile
   put tBundleDir & slash & "dex" into tClassesDir
   revSBEnsureFolder tClassesDir
   revSBCopyFileToFolder tClassesFile, tClassesDir

   // Copy libs into bundle
   local tArch, tLibDir
   put tBundleDir & slash & "lib" into tLibDir
   revSBEnsureFolder tLibDir
   repeat for each key tArch in pArchLibsBuildFolders
      revSBCopyFolderToDestination pArchLibsBuildFolders[tArch], tLibDir
   end repeat

   // Open the assets archive and copy them into the app bundle directory
   set the itemDel to slash
   revZipOpenArchive pAssetArchive, "read"
   if the result is empty then
      local tZipItems
      put revZipEnumerateItems(pAssetArchive) into tZipItems
      local tFolder
      repeat for each line tZipItem in tZipItems
         put item 1 to -2 of tZipItem into tFolder
         revSBEnsureFolder tBundleDir & slash & tFolder
         revZipExtractItemToFile pAssetArchive, tZipItem, tBundleDir & slash & tZipItem
      end repeat
      revZipCloseArchive pAssetArchive
   end if

   // Generate config file for bundle-tool which prevents compression of assets
   local tBundleConfig, tBundleConfigFile
   put pBuildFolder & slash & "BundleConfig.json" into tBundleConfigFile
   put "{" & quote & "compression" & quote & ": {" & quote & "uncompressedGlob" & quote & ": "& \
      "[" & quote & "assets/**" & quote & "]}}" into tBundleConfig
   put tBundleConfig into url ("binfile:" & tBundleConfigFile)

   return empty
end prepareBundle

private command generateBundle \
      pBuildFolder, \
      pPackage, \
      pKey, \
      pKeystoreAlias, \
      pKeystorePassword, \
      pPrivateKeyPassword, \
      pDevice

   local tBundleDir, tBaseArchive
   put pBuildFolder & slash & "aab-bundle" into tBundleDir
   put pBuildFolder & slash & "base.zip" into tBaseArchive

   revZipOpenArchive tBaseArchive, "write"
   if the result is empty then
      local tFile, tList
      put revSBEnumerateFolder(tBundleDir) into tList
      repeat for each line tFile in tList
         if there is a file (tBundleDir & slash & tFile) then
            revZipAddItemWithFile tBaseArchive, tFile, (tBundleDir & slash & tFile)
         end if
      end repeat
      revZipCloseArchive tBaseArchive
   end if

   executeShellCommand pathToJava(), \
         "-jar", \
         pathToBundleTool(), \
         "build-bundle", \
         "--config", pBuildFolder & slash & "BundleConfig.json", \
         "--modules", tBaseArchive, \
         "--output", pPackage

   if the result is not empty then
      throw the result
   end if
   if there is a file tBaseArchive then delete file tBaseArchive

   -- Generate an APK file from the bundle as well
   set the itemDel to "."
   local tApksFile, tApkFile
   put item 1 to -2 of pPackage & ".apks" into tApksFile
   put item 1 to -2 of pPackage & ".apk" into tApkFile

   local tParams
   appendToParams tParams, "-jar"
   appendToParams tParams, pathToBundleTool()
   appendToParams tParams, "build-apks"
   appendToParams tParams, "--bundle", pPackage
   appendToParams tParams, "--output", tApksFile

   if pDevice is empty then
      appendToParams tParams, "--mode", "universal"
   else
      appendToParams tParams, "--connected-device"
      appendToParams tParams, "--device-id", pDevice
      appendToParams tParams, "--adb", pathToAdb()
   end if

   if pKey is not empty then
      appendToParams tParams, "--ks", pKey
      appendToParams tParams, "--ks-pass", "pass:" & pKeystorePassword
      appendToParams tParams, "--ks-key-alias", pKeystoreAlias
      appendToParams tParams, "--key-pass", "pass:" & pPrivateKeyPassword
   end if

   executeShellCommandWithParams \
         pathToJava(), \
         tParams

   local tResult
   put the result into tResult

   if pDevice is empty then
      revZipOpenArchive tApksFile, "read"
      if the result is empty then
         revZipExtractItemToFile tApksFile, "universal.apk", tApkFile
         revZipCloseArchive tApksFile
      end if

      if there is a file tApksFile then delete file tApksFile
   end if
   return tResult
end generateBundle

private command appendToStringList pValue, @xList
   repeat for each line tLine in pValue
      if xList is empty then
         put tLine into xList
      else
         put return & tLine after xList
      end if
   end repeat
end appendToStringList

private command addAndroidDependenciesToSettings @xSettingsA
   local tDependencies
   setMavenDownloadCallback "revStandaloneProgressCallback", the long id of this stack
   resolveAndroidLibraryDependencyList tDependencies, empty, xSettingsA["android,android dependencies"]
   fetchAndroidLibraryDependencies empty, tDependencies, xSettingsA["jarFiles"], xSettingsA["aarFiles"]
   setMavenDownloadCallback empty
end addAndroidDependenciesToSettings

private command expandAARsAndComputeSettings tBuildFolder, @xSettingsA
   local tCount, tDefaultFolder
   put the folder into tDefaultFolder
   repeat for each line tAAR in xSettingsA["aarFiles"]
      local tExtractFolder, tExtractCmd, tExtractedFiles
      add 1 to tCount
      put tBuildFolder & slash & tCount \
            into tExtractFolder
      revSBEnsureFolder tExtractFolder
      set the folder to tExtractFolder
      executeShellCommand pathToJar(), "xf", tAAR
      updateSettingsForExtractedAAR tExtractFolder, xSettingsA
   end repeat
   set the folder to tDefaultFolder
end expandAARsAndComputeSettings
   
constant kSupportedAARFiles = "AndroidManifest.xml,classes.jar,R.txt"   
constant kSupportedAARFolders = "res"
private command updateSettingsForExtractedAAR pFolder, @xSettingsA
   local tExtractedItem, tItemPackage
   repeat for each item tItem in kSupportedAARFiles
      put pFolder & slash & tItem into tExtractedItem
      if there is not a file tExtractedItem then
         next repeat
      end if
      switch tItem
         case "AndroidManifest.xml"
            appendToStringList tExtractedItem, xSettingsA["androidManifests"]
            put getPackageFromAndroidManifestFile(tExtractedItem) into tItemPackage
            break
         case "classes.jar"
            appendToStringList tExtractedItem, xSettingsA["jarFiles"]
            break
         case "R.txt"
            -- Don't need to do anything with this
            break
      end switch
   end repeat
   repeat for each item tItem in kSupportedAARFolders
      put pFolder & slash & tItem into tExtractedItem
      if there is not a folder tExtractedItem then
         next repeat
      end if     
      switch tItem
         case "res"
            if tItemPackage is not empty then
               appendToStringList tItemPackage, xSettingsA["libraryPackages"]
            end if
            -- don't need to do anything with this- our call to aapt
            -- deals with including the res files in the APK
            break
      end switch
   end repeat
end updateSettingsForExtractedAAR

private function getPackageFromAndroidManifestFile pManifestFile
   local tTree, tPackage
   put revXMLCreateTreeFromFile(pManifestFile, false, true, false) into tTree
   put revXMLAttribute(tTree, "/manifest", "package") into tPackage
   revXMLDeleteTree(tTree)
   return tPackage
end getPackageFromAndroidManifestFile

private command addAssetsToArchive pFileData, pBaseFolder, pArchive
   local tDeviceConfig, tConfigFile, tCustomConfigFile, tFonts
   
   put mapFIlePath(revMobileRuntimeFolder() & slash & "lc_device_config.txt") into tConfigFile
   if there is not a file tConfigFile then
      put empty into tConfigFile
   end if
   
   constant kICUDataFiles="icu-coll.dat,icu-core.dat,icu-iter.dat"
   local tIcuDataPath
   local tAndroidPath
   put mapAndroidPath() into tAndroidPath
   set the itemdelimiter to slash
   put "Common/" into item -1 of tAndroidPath
   set the itemdelimiter to comma
   repeat for each item tICUDataFile in kICUDataFiles
      put tAndroidPath & tICUDataFile into tIcuDataPath
      if there is not a file tIcuDataPath then
         throw "could not find icu data '" & tIcuDataPath & "'"
      end if
      revZipAddUncompressedItemWithFile pArchive, "assets/icudata-minimal.dat", tIcuDataPath
   end repeat
   --put mapFilePath(revEnvironmentRuntimePath() & "/Common/icudata-minimal.dat") into tIcuDataPath
   --if there is not a file tIcuDataPath then
   --throw "could not find icu data '" & tIcuDataPath & "'"
   --end if
   --revZipAddUncompressedItemWithFile pArchive, "assets/icudata-minimal.dat", tIcuDataPath
   
   repeat for each element tFile in pFileData
      if there is a file tFile["resolved"] then
         if tConfigFile is not empty and tFile["name"] ends with "lc_device_config.txt" then
            // need to merge config files
            put tFile["resolved"] into tCustomConfigFile
         else if revSBFileIsFontFile(tFile["name"]) then
            -- MM-2012-03-07: [[ Custom fonts ]] If any fonts are found, add to the list so that they are handled correctly
            put tFile["resolved"] & return after tFonts
         else if tFile["name"] ends with ".lcext" or tFile["name"] ends with ".dylib" then
            -- MW-2012-07-05: [[ Externals ]] If an 'lcext' file or dylib file is found then we ignore it.
         else if tFile["name"] ends with "AndroidManifest.xml" then
            -- MW-2015-04-24: [[ TemplateAppMetadata ]] If an template manifest is found then we ignore it.
         else
            revZipAddUncompressedItemWithFile pArchive, "assets/" & tFile["name"], tFile["resolved"]
         end if
      else if there is a folder tFile["resolved"] then
         if not (tFile["resolved"] ends with ".lcextd") then
            addAssetsFromFolderToArchive tFile["resolved"], "assets" & slash & tFile["name"], pArchive, tFonts
         end if
      else
         throw "could not find referenced asset to include -" && tFile["resolved"]
      end if
   end repeat
   
   if tCustomConfigFile is empty then
      if tConfigFile is not empty then
         revZipAddUncompressedItemWithFile pArchive, "assets/lc_device_config.txt", tConfigFile
      end if
   else
      put url ("binfile:" & tConfigFile) & return into tDeviceConfig
      put url ("binfile:" & tCustomConfigFile) after tDeviceConfig
      revZipAddUncompressedItemWithData pArchive, "assets/lc_device_config.txt", "tDeviceConfig"
   end if
   
   -- MM-2012-03-07: [[ Custom fonts ]] Add any fonts found to the assets/fonts folder
   set the itemDel to slash
   repeat for each line tFont in tFonts
      if tFont is not empty then
         revZipAddUncompressedItemWithFile pArchive, "assets/fonts/" & item -1 of tFont, tFont
      end if
   end repeat
   set the itemDel to comma   
end addAssetsToArchive

private command addAssetsFromFolderToArchive pFolder, pBaseName, pArchive, @pFonts
   set the itemDelimiter to slash
   
   -- Ignore any .svn folders
   if the last item of pFolder is ".svn" then
      exit addAssetsFromFolderToArchive
   end if

   if char -1 of pFolder is slash then
      delete char -1 of pFolder
   end if
   
   local tOldFolder
   put the folder into tOldFolder
   set the folder to pFolder
   if the folder is not pFolder then
      throw "could not descend into referenced asset folder -" && pFolder
   end if
   
   repeat for each line tFile in the files
      if revSBFileIsFontFile(tFile) then
         -- MM-2012-03-07: [[ Custom fonts ]] If any fonts are found, add to the list so that they are handled correctly
         put the folder & slash & tFile & return after pFonts
      else if tFile ends with ".lcext" or tFile ends with ".dylib" then
         -- MW-2012-07-05: [[ Externals ]] If an 'lcext' file or dylib file is found then we ignore it.
      else
         revZipAddUncompressedItemWithFile pArchive, pBaseName & slash & tFile, the folder & slash & tFile
      end if
   end repeat
   
   repeat for each line tFolder in the folders
      if tFolder is ".." then
         next repeat
      end if
      
      addAssetsFromFolderToArchive pFolder & slash & tFolder, pBaseName & slash & tFolder, pArchive, pFonts
   end repeat
   
   set the folder to tOldFolder
end addAssetsFromFolderToArchive

################################################################################

private function fileIsZipArchive pFile
   open file pFile for binary read
   if the result is empty then
      read from file pFile for 4 bytes
      close file pFile
   end if
   if it is empty then
      throw "could not open external -" && pFile
   end if
   
   return byte 1 of it is "P" and byte 2 of it is "K" and byte 3 of it is numToChar(3) and byte 4 of it is numToChar(4)
end fileIsZipArchive

-- MERG-2013-09-05: [[ Bug 11152 ]]  Change to function - returns true if external was successfully
--   extracted.
private function addExternalFromFile pExternal, pClassesFolder, pArchLibsFolders, @rJarFiles
   -- If the file is not a zip archive then there is nothing to do.
   if not fileIsZipArchive(pExternal) then
      exit addExternalFromFile
   end if
   
   -- Get the name of the external.
   local tExternalName
   set the itemDelimiter to slash
   get the last item of pExternal
   set the itemDelimiter to "."
   put the first item of it into tExternalName
   set the itemDelimiter to slash
   
   -- Compute the class / lib names.
   local tClassesFile, tLibFileA, tJarPrefix
   put pClassesFolder & slash & "lib" & tExternalName into tJarPrefix
   put tJarPrefix & ".jar" into tClassesFile
   
   -- Otherwise open the archive and check for appropriate android components
   revZipOpenArchive pExternal, "read"
   if the result is empty then
      
      -- MERG-2015-10-14: [[ ThirdpartyLibs ]] Add support for thirdparty librares
      local tZipItems
      put revZipEnumerateItems(pExternal) into tZipItems
      filter tZipItems with "Android/*"
      
      local tZipItemsFiltered
      filter tZipItems with regex pattern ".*(\.jar|Classes)$" into tZipItemsFiltered
      repeat for each line tZipItem in tZipItemsFiltered
         if tZipItem ends with ".jar" then
            local tJarPath
            put tJarPrefix & "-" & the last item of tZipItem & ".jar" into tJarPath
            revZipExtractItemToFile pExternal, tZipItem, tJarPath
            appendToStringList tJarPath, rJarFiles
         else 
            # will be Classes file
            revZipExtractItemToFile pExternal, tZipItem, tClassesFile
            appendToStringList tClassesFile, rJarFiles
         end if
      end repeat
      
      repeat for each key tArch in pArchLibsFolders
         local tPattern
         put "^Android/(?:External-" & tArch & "|lib.+" & tArch & "\.so)$" into tPattern
         filter tZipItems with regex pattern tPattern into tZipItemsFiltered
         put pArchLibsFolders[tArch] & slash & "lib" & tExternalName & ".so" into tLibFileA[tArch]
         
         repeat for each line tZipItem in tZipItemsFiltered
            if tZipItem ends with ".so" then
               revZipExtractItemToFile pExternal, tZipItem, \
                     pArchLibsFolders[tArch] & slash & the last item of tZipItem 
            else 
               # will be External-<Arch> file
               revZipExtractItemToFile pExternal, tZipItem, tLibFileA[tArch]
            end if
         end repeat
      end repeat
      
      revZipCloseArchive pExternal
   end if
   
   if there is a file tClassesFile then
      repeat for each key tArch in pArchLibsFolders
         if there is no file tLibFileA[tArch] then
            throw "android external contains classes but no library for " & tArch
         end if
      end repeat
   end if
   
   return tLibFileA is an array
end addExternalFromFile

private function addExternalFromFolder pExternal, pClassesFolder, pArchLibsFolders, @rJarFiles
   -- Get the name of the external.
   local tExternalName
   set the itemDelimiter to slash
   get the last item of pExternal
   set the itemDelimiter to "."
   put the first item of it into tExternalName
   set the itemDelimiter to slash
   
   -- Compute the class / lib names.
   local tClassesFile, tLibFileA, tJarPrefix
   put pClassesFolder & slash & "lib" & tExternalName into tJarPrefix
   put tJarPrefix & ".jar" into tClassesFile
   
   local tItems
   put files(pExternal & "/Android") into tItems
   
   local tItemsFiltered
   filter tItems with regex pattern ".*(\.jar|Classes)$" into tItemsFiltered
   repeat for each line tItem in tItemsFiltered
      if tItem ends with ".jar" then
         local tJarPath
         put tJarPrefix & "-" & the last item of tItem & ".jar" into tJarPath
         revSBCopyFile pExternal & "/Android/" & tItem, tJarPath
         appendToStringList tJarPath, rJarFiles
      else 
         # will be Classes file
         revSBCopyFile pExternal & "/Android/" & tItem, tClassesFile
         appendToStringList tClassesFile, rJarFiles
      end if
   end repeat
   
   repeat for each key tArch in pArchLibsFolders
      local tPattern
      put "^(?:External-" & tArch & "|lib.+" & tArch & "\.so)$" into tPattern
      filter tItems with regex pattern tPattern into tItemsFiltered
      put pArchLibsFolders[tArch] & slash & "lib" & tExternalName & ".so" into tLibFileA[tArch]
      repeat for each line tItem in tItemsFiltered
         if tItem ends with ".so" then
            revSBCopyFile pExternal & "/Android/" & tItem, \
                  pClassesFolder & slash & the last item of tItem 
         else 
            # will be External-<Arch> file
            revSBCopyFile pExternal & "/Android/" & tItem, \
                  tLibFileA[tArch]
         end if
      end repeat
   end repeat
   
   if there is a file tClassesFile then
      repeat for each key tArch in pArchLibsFolders
         if there is no file tLibFileA[tArch] then
            throw "android external contains classes but no library for " & tArch
         end if
      end repeat
   end if
   
   return tLibFileA is an array
end addExternalFromFolder

################################################################################

private function revMobileRuntimeFolder pTarget
   local tOverridePath, tUserPath
   
   # TODO: fix this
   return pathToRepoAndroidBinaries()
   
   // IM-2013-12-16: [[ Bug 11594 ]] Check override is not empty to avoid accidentally detecting "/Android" path
   if revOverrideRuntimePath() is not empty then
      put revOverrideRuntimePath() & slash & "Android" into tOverridePath
      if there is a folder tOverridePath then
         return tOverridePath
      end if
   end if
   
   // IM-2013-12-16: [[ Bug 11594 ]] Check override is not empty to avoid accidentally detecting "/Android" path
   if revEnvironmentUserRuntimePath() is not empty then
      put revEnvironmentUserRuntimePath() & slash & "Android" into tUserPath
      if there is a folder tUserPath then
         return tUserPath
      end if
   end if
   
   return revEnvironmentRuntimePath() & slash & "Android"
end revMobileRuntimeFolder

################################################################################

private command executeAdbCommand pCommand
   local tAdb
   put pathToAdb() into tAdb
   if tAdb is empty or there is not a file tAdb then
      exit executeAdbCommand
   end if
   
   get doShellCommand(tAdb, pCommand)
   
   return it
end executeAdbCommand

private command appendToList pValue, @xList
   get the number of elements in xList
   put pValue into xList[it + 1]
end appendToList

private command appendToParams @xParams
   repeat with i = 2 to the paramCount
      appendToList param(i), xParams
   end repeat
end appendToParams

private command prependToList pValue, @xList
   insertIntoList pValue, xList, 1
end prependToList

private command insertIntoList pValue, @xList, pAt
   local tNewList
   repeat with x = the number of elements in xList down to 1
      if x >= pAt then
         put xList[x] into tNewList[x+1]
      else
         put xList[x] into tNewList[x]
      end if
   end repeat
   put pValue into tNewList[pAt]
   put tNewList into xList
end insertIntoList
   
private function shellEscape pString
   switch the platform
      case "MacOS"
      case "Linux"
         replace "\" with "\\" in pString
         replace quote with "\" & quote in pString
         replace "`" with "\`" in pString
         replace "$" with "\$" in pString
         return quote & pString & quote
      case "Win32"
         return q(pString)
      default
         throw "Unhandled platform" && the platform
   end switch
end shellEscape

private command executeShellCommand
   local tArray
   repeat with i = 2 to the paramCount
      appendToList param(i), tArray
   end repeat
   
   executeShellCommandWithParams param(1), tArray
   return the result
end executeShellCommand

private command executeShellCommandWithParams pCommand, pParamArray
   local tShell
   repeat for each element tParam in pParamArray
      if not (tParam begins with "-") then
         put shellEscape(tParam)into tParam
      end if   
      put tParam & space after tShell
   end repeat
   
   get doShellCommand(pCommand, tShell)
   
   return it
end executeShellCommandWithParams

private function doShellCommand pCommand, pArguments
   --makeBuildLogEntry "Executing command:" && pCommand && pArguments
   
   local tCommandPath
   set the itemDelimiter to slash
   put item 1 to -2 of pCommand into tCommandPath
   if the platform is "win32" then
      put shortFilePath(tCommandPath) into tCommandPath
   end if
   
   local tOldPath
   put $PATH into tOldPath
   if the platform is "win32" then
      replace slash with backslash in tCommandPath
      put tCommandPath & ";" & sJavaRoot & "\bin" & ";" before $PATH
   else if the platform is "macos" then
      put tCommandPath & ":" before $PATH
   else if the platform is "linux" then
      put tCommandPath & ":" & sJavaRoot & "/bin" & ":" before $PATH
   end if
   
   set the hideConsoleWindows to true
   write item -1 of pCommand && pArguments & return to stderr
   get shell(item -1 of pCommand && pArguments)
   
   put tOldPath into $PATH
   
   return it
end doShellCommand

################################################################################

constant kDeployLibrary = "revDeployLibraryAndroid"
private function targetSDKVersion
   dispatch function "deployTargetSdkVersion" to stack kDeployLibrary
   return the result
end targetSDKVersion

private function pathToRootClasses pRoot
   dispatch function "pathToRootClasses" to stack kDeployLibrary with pRoot
   return the result
end pathToRootClasses

private function pathToSDKClasses pRoot
   dispatch function "pathToSDKClasses" to stack kDeployLibrary with pRoot
   return the result
end pathToSDKClasses

private function pathToCommonClasses pRoot
   dispatch function "pathToCommonClasses" to stack kDeployLibrary with pRoot
   return the result
end pathToCommonClasses

private function pathToAapt2 pRoot
   dispatch function "pathToAapt2" to stack kDeployLibrary with pRoot
   return the result
end pathToAapt2

private function pathToBundleTool
   dispatch function "pathToBundleTool" to stack kDeployLibrary
   return the result
end pathToBundleTool

private function pathToAdb pRoot
   dispatch function "pathToAdb" to stack kDeployLibrary with pRoot
   return the result
end pathToAdb

private function pathToAPKSigner pRoot
   dispatch function "pathToAPKSigner" to stack kDeployLibrary with pRoot
   return the result
end pathToAPKSigner

private function pathToDebugKey pRoot
   dispatch function "pathToDebugKey" to stack kDeployLibrary with pRoot
   return the result
end pathToDebugKey

private function pathToZipAlign pRoot
   dispatch function "pathToZipAlign" to stack kDeployLibrary with pRoot
   return the result
end pathToZipAlign

# NOTE: pContext is always empty
private command setMavenDownloadCallback pHandler, pObjectId, pContext
   dispatch "setMavenDownloadCallback" to stack kDeployLibrary with pHandler, pObjectId, pContext
end setMavenDownloadCallback

private command resolveAndroidLibraryDependencyList @xDependencies, pRoot, pDependencyList
   dispatch "resolveAndroidLibraryDependencyList" to stack kDeployLibrary with xDependencies, pRoot, pDependencyList
end resolveAndroidLibraryDependencyList

private command fetchAndroidLibraryDependencies pRoot, pDependencies, @xJarFiles, @xAarFiles
   dispatch "fetchAndroidLibraryDependencies" to stack kDeployLibrary with pRoot, pDependencies, xJarFiles, xAarFiles
end fetchAndroidLibraryDependencies

private function getRepoBinariesFolder pArch
   return mapAndroidPath(pArch)
end getRepoBinariesFolder

// SN-2015-07-02: [[ GypifiedAndroid ]] Get the right folder for android binaries
private function pathToRepoAndroidBinaries pArch
   local tBuild
   if revEnvironmentBinariesPath() contains "/Debug" then
      put "Debug" into tBuild
   else
      put "Release" into tBuild
   end if
   --   return revEnvironmentRepositoryPath() & "/build-android-" & pArch & "/out/" & tBuild
   return getRepoBinariesFolder()
end pathToRepoAndroidBinaries

private function pathToD8 pRoot
   dispatch function "pathToD8" to stack kDeployLibrary with pRoot
   return the result
end pathToD8

private function pathToJavaC pRoot
   dispatch function "pathToJavaC" to stack kDeployLibrary with pRoot
   return the result
end pathToJavaC

private function pathToJava pRoot
   dispatch function "pathToJava" to stack kDeployLibrary with pRoot
   return the result
end pathToJava

private function pathToJarSigner pRoot
   dispatch function "pathToJarSigner" to stack kDeployLibrary with pRoot
   return the result
end pathToJarSigner

private function pathToJar pRoot
   dispatch function "pathToJar" to stack kDeployLibrary with pRoot
   return the result
end pathToJar

private function pathToKeytool pRoot
   dispatch function "pathToKeytool" to stack kDeployLibrary with pRoot
   return the result
end pathToKeytool

################################################################################

private function mapAndroidPath pArch
   set the itemdelimiter to slash
   return slash & (item 2 to -2 of the address) & "/Runtime/Android/" & pArch
end mapAndroidPath

-- MW-2013-06-13: [[ CloneAndRun ]] Map a file path from where the sb expects them to be to local
--   files in the build folder.
private function mapFilePath pPath
   if revEnvironmentIsInstalled() then
      // SN-2015-01-19: [[ Bug 13213 ]] Linux filepaths are case-sensitive.
      //   so we try to caselessly match the targetted file, with the actual files.
      set the itemDelimiter to slash
      
      // Get the list of files in the targetted directory
      local tOldFolder, tFiles
      put the defaultFolder into tOldFolder
      set the defaultFolder to item 1 to -2 of pPath
      
      put the files into tFiles
      set the defaultFolder to tOldFolder
      
      local tLineOffset
      put lineOffset(last item of pPath, tFiles) into tLineOffset
      
      // We return empty if we can't find the specified file
      // That will allow us to throw an error in such a case.
      if tLineOffset is 0 then
         return empty
      else
         put line tLineOffset of tFiles into item -1 of pPath
      end if
      return pPath
   end if
   
   local tPath
   local tBinariesFolder, tComponent, tSuffix
   local tArch, tFoundArch
   repeat for each item tItem in revSBPlatformArchitectures("Android")
      if pPath contains ("/" & __ArchABI(tItem) & "/") then
         put tItem into tArch
      end if

      if tFoundArch is empty and \
            there is a folder pathToRepoAndroidBinaries(tItem) then
         put tItem into tFoundArch
      end if
   end repeat

   if tArch is empty then
      put tFoundArch into tArch
   end if

   put pathToRepoAndroidBinaries(tArch) into tBinariesFolder
   
   // SN-2015-07-02: [[ GypifiedAndroid ]] Throw an error if there is
   //  not the expected build folder
   if there is no folder tBinariesFolder then
      throw "Error: Android binaries folder" && tBinariesFolder && "could not be found"
   end if
   
   set the itemDelimiter to slash
   put the last item of pPath into tComponent
   
   switch tComponent
      case "notify_icon.png"
         put merge("[[tBinariesFolder]]/notify_icon.png") into tPath
         break
      case "Manifest.xml"
         put merge("[[tBinariesFolder]]/Manifest.xml") into tPath
         break
      case "nfc_tech_filter.xml"
         put merge("[[tBinariesFolder]]/nfc_tech_filter.xml") into tPath
         break
      case "file_provider_paths.xml"
         put merge("[[tBinariesFolder]]/file_provider_paths.xml") into tPath
         break
      case "livecode_inputcontrol.xml"
         put merge("[[tBinariesFolder]]/livecode_inputcontrol.xml") into tPath
         break
      case "Classes"
         put merge("[[tBinariesFolder]]/Classes") into tPath
         break
      case "Standalone"
         put merge("[[tBinariesFolder]]/Standalone") into tPath
         break
      case "icudata-minimal.dat"
         put merge("[[tBinariesFolder]]/icudata-minimal.dat") into tPath
         break
      case "revzip"
         put merge("[[tBinariesFolder]]/RevZip") into tPath
         break
      case "revdb"
         put merge("[[tBinariesFolder]]/RevDb") into tPath
         break
      case "revxml"
         put merge("[[tBinariesFolder]]/RevXml") into tPath
         break
      case "dbsqlite"
         put merge("[[tBinariesFolder]]/DbSqlite") into tPath
         break
      case "dbmysql"
         put merge("[[tBinariesFolder]]/DbMysql") into tPath
         break
      case "revsecurity"
         put merge("[[tBinariesFolder]]/RevSecurity") into tPath
         break
      case "revpdfprinter"
         put merge("[[tBinariesFolder]]/RevPdfPrinter") into tPath
         break
      default
         put pPath into tPath
         break
   end switch
   
   return tPath
end mapFilePath

################################################################################

private function androidCreateAppManifest pMainManifest, pAdditionalManifestsA, pBuildVariables
   local tMainArrayA, tAdditionalArraysA
   put androidManifestToArray(pMainManifest, pBuildVariables) into tMainArrayA
   repeat for each element tManifest in pAdditionalManifestsA
      appendToList androidManifestToArray(tManifest, pBuildVariables), tAdditionalArraysA
   end repeat
   
   MergeManifestArrays tMainArrayA, tAdditionalArraysA
   return ConvertArrayToXML(tMainArrayA, "utf-8")
end androidCreateAppManifest

private command mergeManifestArrays @xManifestArrayA, pAdditionalsA
   repeat for each element tAdditionalA in pAdditionalsA
      mergeManifestElementList xManifestArrayA, tAdditionalA
   end repeat
end mergeManifestArrays

constant kMergePolicyMerge = "merge"
constant kMergePolicyMergeChildrenOnly = "mergeChildrenOnly"
constant kMergePolicyKeep = "keep"
private function mergeElementPolicy pManifestElement
   switch pManifestElement["@name"]
      case "action"
      case "activity"
      case "application"
      case "category"
      case "data"
      case "grant-uri-permission"
      case "instrumentation"
      case "meta-data"
      case "path-permission"
      case "permission-group"
      case "permission"
      case "permission-tree"
      case "provider"
      case "receiver"
      case "screen"
      case "service"
      case "supports-gl-texture"
      case "supports-screen"
      case "uses-configuration"
      case "uses-feature"
      case "uses-library"
      case "uses-permission"
      case "uses-sdk"
         return kMergePolicyMerge
         break
      case "intent-filter"
         return kMergePolicyKeep
         break
      case "manifest"
         return kMergePolicyMergeChildrenOnly
         break
      default
         // Don't merge custom elements
         return kMergePolicyKeep
         break
   end switch
end mergeElementPolicy

private function mergeElementMatch? pElementA, pElementB
   if pElementA["@name"] is not pElementB["@name"] then
      // Different types of element do not match
      return false
   end if
   switch pElementA["@name"]
      case "action"
      case "activity"
      case "category"
      case "instrumentation"
      case "meta-data"
      case "permission-group"
      case "permission"
      case "permission-tree"
      case "provider"
      case "receiver"
      case "service"
      case "supports-gl-texture"
      case "uses-library"
      case "uses-permission"
         // Match on "android:name" attribute
         return pElementA["@attributes"]["android:name"] is pElementB["@attributes"]["android:name"]
         break
      case "uses-feature"
         // Match on "android:name" attribute if present, otherwise match on "android:glEsVersion" attribute
         if "android:name" is among the keys of pElementA["@attributes"] and "android:name" is among the keys of pElementB["@attributes"] then
            return pElementA["@attributes"]["android:name"] is pElementB["@attributes"]["android:name"]
         else if "android:glEsVersion" is among the keys of pElementA["@attributes"] and "android:glEsVersion" is among the keys of pElementB["@attributes"] then
            return pElementA["@attributes"]["android:glEsVersion"] is pElementB["@attributes"]["android:glEsVersion"]
         else
            return false
         end if
         break
      case "screen"
         // Match on "android:screenSize" attribute
         return pElementA["@attributes"]["android:screenSize"] is pElementB["@attributes"]["android:screenSize"]
         break
      case "application" // Only one per manifest - always match
      case "data" // Only one per intent-filter - always match
      case "grant-uri-permission" // Only one per provider - always match
      case "manifest" // Only one per file - always match
      case "path-permission" // Only one per provider - always match
      case "supports-screen" // Only one per manifest - always match
      case "uses-configuration" // Only one per manifest - always match
      case "uses-sdk" // Only one per manifest - always match
         return true
         break
      case "intent-filter" // Multiple declarations within parent - no matching
         return false
         break
      default
         // Don't match custom elements
         return false
   end switch
end mergeElementMatch?

private command mergeManifestElementList @xManifestElements, pNewElements
   repeat for each element tNew in pNewElements
      // find matching element index (if any)
      local tMatch
      put empty into tMatch
      repeat with i = 1  to the number of elements in xManifestElements
         if mergeElementMatch?(xManifestElements[i], tNew) then
            put i into tMatch
            exit repeat
         end if
      end repeat
      if tMatch is empty or mergeElementPolicy(tNew) is kMergePolicyKeep then
         // append element to list
         appendToList tNew, xManifestElements
      else
         // merge matching elements
         mergeManifestElements xManifestElements[i], tNew
      end if
   end repeat
end mergeManifestElementList

private command mergeManifestElements @xElement, pNewElement
   local tMergePolicy
   put mergeElementPolicy(xElement) into tMergePolicy
   if tMergePolicy is kMergePolicyMerge then
      // merge element attributes
      repeat for each key tKey in pNewElement["@attributes"]
         if tKey begins with "tools:" then
            /* TODO - implement merge conflict resolution using "tools:" attributes */
            next repeat
         end if
         
         if xElement["@name"] is "uses-sdk" then
            if tKey is "minSdkVersion" then
               /* NON_STANDARD - merging a library with a higher minSdkVersion is typically an error,
               instead we bump up the minSdkVersion in the combined manifest to match */
               put max(xElement["@attributes"]["minSdkVersion"], pNewElement["@attributes"]["minSdkVersion"]) into xElement["@attributes"]["minSdkVersion"]
            end if
         else if tKey is not among the keys of xElement["@attributes"] then
            put pNewElement["@attributes"][tKey] into xElement["@attributes"][tKey]
         else if tKey is "android:required" and xElement["@name"] is among the items of "uses-feature,uses-library" then
            put xElement["@attributes"][tKey] or pNewElement["@attributes"][tKey] into xElement["@attributes"][tKey]
         else if xElement["@attributes"][tKey] is not pNewElement["@attributes"][tKey] then
            throw "merge conflict: attibute value mismatch"
         end if
      end repeat
   end if
   if tMergePolicy is kMergePolicyMerge or tMergePolicy is kMergePolicyMergeChildrenOnly then
      // merge element children
      mergeManifestElementList xElement["@children"], pNewElement["@children"]
   end if
end mergeManifestElements

private command replaceAndroidManifestPlaceholders @xManifestXMLData, pBuildVariables
   -- The only placeholder encountered so far is the "${applicationId}" placeholder
   replace "${applicationId}" with pBuildVariables["applicationId"] in xManifestXMLData
end replaceAndroidManifestPlaceholders

private function androidManifestToArray pManifestFile, pBuildVariables
   local tXML
   put url("binfile:" & pManifestFile) into tXML
   replaceAndroidManifestPlaceholders tXML, pBuildVariables
   return ConvertXMLToArray(tXML, "utf-8", true, "")
end androidManifestToArray

/*
Handlers for converting XML text to LiveCode arrays and vice versa. 
Based on an implementation by Trevor DeVore of Blue Mango Learning Systems.
*/

/**
Converts an XML tree into a LiveCode multi-dimensional array.

Parameters:
pXML: The xml to convert.
pStoreEncodedAs: 
Encoding to use. Must be a value that can be passed to textEncode. Default is "utf-8".
*/
private function ConvertXMLToArray pXML, pStoreEncodedAs
   local theArray,theResult,theRootNode,theTreeID
   local theXMLEncoding, tVersion
   
   ## Create an XML tree from XML text
   put revCreateXMLTreeWithNamespaces(pXML, true, true, false) into theTreeID
   
   if theTreeID is an integer then
      ## Determine the encoding of the XML, default to UTF-8
      put matchText(pXML, "<?xml (.)encoding=" & quote & "([^" & quote & "])", tVersion, theXMLEncoding) into theResult
      if theXMLEncoding is empty then put "utf-8" into theXMLEncoding
      
      ## Now convert to array. 
      ## The 1st dimension has one key which is the name of the root node.
      put revXMLRootNode(theTreeID) into theRootNode
      if theRootNode is not empty and not(theRootNode begins with "xmlerr,") then
         put ConvertXMLNodeToArray(theTreeID, theRootNode, theXMLEncoding, pStoreEncodedAs) \
               into theArray[1]
         put theRootNode into theArray[1]["@name"]
      end if
      
      revDeleteXMLTree theTreeID
   end if
   
   return theArray
end ConvertXMLToArray


/**
Converts a revXML created XML Tree to an array.
Parameters:
pXMLTree: The xml tree id.
pStoreEncodedAs: See docs for ConvertXMLToArray.

Description:
See docs for ConvertXMLToArray.
*/
private function ConvertXMLTreeToArray pXMLTree, pStoreEncodedAs
   return ConvertXMLToArray(revXMLText(pXMLTree), pStoreEncodedAs)
end ConvertXMLTreeToArray


/**
Converts a multi-dimensional array to an XML tree.
Parameters:
pArray: The array to convert.
pArrayEncoding: Encoding used in the array. Must be a value that can be passed to textDecode.
pStoreEncodedAs: Encoding to use. Must be a value that can be passed to textEncode. Default is "utf-8".

Description:
The array should be keyed numerically, in order of appearance of nodes.
pArray[1] is assumend to be the root node in the XML tree.
each node is an array with three possible keys, 
- @name (required): The name of the node
- @attributes: The attributes of the node, stored as an array of 
  name/value pairs
- @children: A numerically keyed array of child nodes
- @value: The text value of the node
Returns: Text of the XML represented by the array, or error message.
*/
private function ConvertArrayToXML pArray, pArrayEncoding, pStoreEncodedAs
   local theError,theRootNode,theXML,theXMLTree
   
   ## if pArrayEncoding is empty then current platform encoding is assumed
   if pStoreEncodedAs is empty then put "UTF-8" into pStoreEncodedAs
   
   ## Create XML for root node. Note that we take extra steps in order to support
   ## converting an array that only represents part of a tree rather than the entire tree.
   ## In this case there may be multiple nodes at the root level.
   put pArray[1]["@name"] into theRootNode 
   put "<" & theRootNode & "/>" into theXML
   
   local tEncoding
   ## Create XML needed to create tree
   put format("<?xml version=\"1.0\" encoding=\"%s\"?>", \
         pStoreEncodedAs) into tEncoding
   put tEncoding before theXML
   put revCreateXMLTreeWithNamespaces(theXML, true, true, false) into theXMLTree
   
   if theXMLTree is an integer then
      ## Loop over all nodes at root level
      ## Create tree using helper function
      local tName
      repeat for each element tNode in pArray
         put tNode["@name"] into tName
         replace space with "-" in tName
         ConvertArrayDimensionToXML tNode, theXMLTree, slash & tName, \
               tName, pArrayEncoding, pStoreEncodedAs
         put the result into theError
         
         if theError is not empty then exit repeat
      end repeat
      
      if theError is not empty then
         ## something went wrong, clean bad tree
         revDeleteXMLTree theXMLTree
      end if
   else
      put theXMLTree into theError
   end if
   
   if theError is not empty then
      return theError for error
   else
      return tEncoding & return & \
            revXMLText(theXMLTree, theRootNode, true) \
            for value
   end if
end ConvertArrayToXML
 
private command ConvertArrayDimensionToXML pArray, pTreeID, pNode, pName, pArrayEncoding, pStoreEncodedAs
   local theError,theKey,theKeys,tName
   put pName into tName
   repeat for each key tKey in pArray
      if tKey is "@name" then next repeat
      ## Look for attributes. These will be added as attributes to pNode.
      if tKey is "@attributes" or tKey is "@attr" then
         repeat for each key theKey in pArray[tKey]
            local theAttr
            put theKey into theAttr
            replace space with "-" in theAttr
            
            revSetXMLAttribute pTreeID, pNode, theAttr, \
                  EncodeString(pArray[tKey][theKey], \
                  pArrayEncoding, pStoreEncodedAs)
            if the result begins with "xmlerr," then 
               put the result && "(setting attribute" && theKey && "for node" && pNode & ")" into theError
            end if
            
            if theError is not empty then exit repeat
         end repeat
         
      else if tKey is "@value" then
         ## This XML tree is using complex structure. Node is the value of the parent node
         revPutIntoXMLNode pTreeID, pNode, EncodeString(pArray[tKey], pArrayEncoding, pStoreEncodedAs)
         if the result begins with "xmlerr," then
            put the result && "(adding child node" && tName && "to node" && pNode & ")" into theError
         end if
         
      else if tKey is "@children" then
         local tCounts
         repeat for each element tChildNode in pArray[tKey]
            add 1 to tCounts[tChildNode["@name"]]
            ## Node has children. Add node to XML tree then call self recursivly to create children nodes. 
            revAddXMLNode pTreeID, pNode, tChildNode["@name"], empty
            if the result begins with "xmlerr," then
               put the result && "(adding node" && tName & ")" into theError
            end if
            
            if theError is empty then
               ConvertArrayDimensionToXML tChildNode, pTreeID, \
                     pNode & slash & tChildNode["@name"] & "[" & tCounts[tChildNode["@name"]] & "]", \
                     tChildNode["@name"], pArrayEncoding, pStoreEncodedAs
               put the result into theError
            end if
         end repeat
      else
         ## Node has no children but possibly a value. Create node and add value (which may be empty).
         revAddXMLNode pTreeID, pNode, tKey, \
               EncodeString(pArray[tKey], pArrayEncoding, pStoreEncodedAs)
         if the result begins with "xmlerr," then
            put the result && "(adding child node" && tKey && "to node" && pNode & ")" into theError
         end if
      end if
      if theError is not empty then exit repeat
   end repeat
   
   return theError
end ConvertArrayDimensionToXML
 
private function ConvertXMLNodeToArray pTreeID, pNode, pXMLTreeEncoding, pStoreEncodedAs
   local theArrayA,theAttributes,theChildNode,theKey
   
   ## Look for attributes of the node. Store as array in "@attributes" key
   put revXMLAttributes(pTreeID, pNode, tab, cr) into theAttributes
   if theAttributes is not empty then
      put EncodeString(theAttributes, pXMLTreeEncoding, pStoreEncodedAs) into theAttributes
      split theAttributes by cr and tab -- create array
      put theAttributes into theArrayA["@attributes"]
   end if
   
   ## Look for children nodes. 
   set the itemDelimiter to slash
   put revXMLFirstChild(pTreeID, pNode) into theChildNode
   if theChildNode is empty or theChildNode begins with "xmlerr," then
      local theValue
      put EncodeString(revXMLNodeContents(pTreeID, pNode), pXMLTreeEncoding, pStoreEncodedAs) into theValue
      if word 1 to -1 of theValue is empty and the keys of theArrayA is not empty then
         ## Empty node that has attributes
         return theArrayA
         ## Force value into @value
         put theValue into theArrayA["@value"]
         return theArrayA
      end if
   else
      ## Child nodes were found. Recursively call self and store result in array.
      set the wholeMatches to true
      local tIndex
      repeat while theChildNode is not empty and not (theChildNode begins with "xmlerr,")
         add 1 to tIndex
         put the last item of theChildNode into theKey
         set the itemdelimiter to "["
         if the number of items in theKey > 1 then
            put item 1 to -2 of theKey into theKey
         end if    
         set the itemdelimiter to slash
         put ConvertXMLNodeToArray(pTreeID, theChildNode, pXMLTreeEncoding, pStoreEncodedAs) into theArrayA["@children"][tIndex]
         put theKey into theArrayA["@children"][tIndex]["@name"]
         put revXMLNextSibling(pTreeID, theChildNode) into theChildNode
      end repeat
      
      return theArrayA
   end if
end ConvertXMLNodeToArray
 
private function EncodeString pString, pInEncoding, pOutEncoding
   if pInEncoding is pOutEncoding then
      return pString
   end if
   
   if pInEncoding is not empty then
      -- if pOutEncoding is empty then pString will be converted to the current platform encoding
      put textDecode(pString, pInEncoding) into pString
   end if
   
   if pOutEncoding is not empty then
      -- if pInEncoding is empty then pString is assumed to be in the current platform encoding
      put textEncode(pString, pOutEncoding) into pString
   end if
   
   return pString
end EncodeString

##########

private function getGoogleServicesStringResources pAppId, pJSON
   local tResources
   local tGS
   
   try
      put JSONImport(pJSON) into tGS
   catch tException
      return empty
   end try
   
   local tGoogleApiKey, tGoogleAppId
   repeat for each element tClient in tGS["client"]
      if tClient["client_info"]["android_client_info"]["package_name"] is pAppId then
         put tClient["api_key"][1]["current_key"] into tGoogleApiKey
         put tClient["client_info"]["mobilesdk_app_id"] into tGoogleAppId
      end if
   end repeat
   
   if tGoogleApiKey is not empty then
      put tGoogleApiKey into tResources["google_api_key"]
   end if
   
   if tGoogleAppId is not empty then
      put tGoogleAppId into tResources["google_app_id"]
   end if
   
   local tGCMDefaultSenderId
   put tGS["project_info"]["project_number"] into tGCMDefaultSenderId
   if tGCMDefaultSenderId is not empty then
      put tGCMDefaultSenderId into tResources["gcm_defaultSenderId"]
   end if
   
   local tGoogleStorageBucket
   put tGS["project_info"]["storage_bucket"] into tGoogleStorageBucket
   if tGoogleStorageBucket is not empty then
      put tGoogleStorageBucket into tResources["google_storage_bucket"]
   end if
   
   local tProjectId
   put tGS["project_info"]["project_id"] into tProjectId
   if tProjectId is not empty then
      put tProjectId into tResources["project_id"]
   end if
   
   return tResources
end getGoogleServicesStringResources

private function generateStringResourceXML pStringResources
   local tXML
   put "<?xml version="&q("1.0")&" encoding="&q("utf-8")&"?>" & cr after tXML
   put "<resources>" & cr after tXML
   repeat for each key tKey in pStringResources
      put "<string name="&q(tKey)&" translatable="&q("false")&">"&pStringResources[tKey]&"</string>"&cr after tXML
   end repeat
   put "</resources>" & cr after tXML
   return tXML
end generateStringResourceXML

private function q pText
   return quote & pText & quote
end q
################################################################################
