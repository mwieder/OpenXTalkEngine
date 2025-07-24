script "engineBuilderRun"
---------------------------------------------------------------------

private function engineBuilderRun.VM.RunPath
   return "/Applications/VMware Fusion.app/Contents/Library/VMrun"
end engineBuilderRun.VM.RunPath

private function engineBuilderRun.VM.Folder
   return "/Users/michael/Documents/Virtual Machines"
end engineBuilderRun.VM.Folder

private function engineBuilderRun.Windows.VM.Path
   return engineBuilderRun..VM.Folder() & "/Windows - Build.VM.ware.VM"
end engineBuilderRun.Windows.VM.Path

private function engineBuilderRun.Linux.VM.Path
   return engineBuilderRun.VM.Folder() & "/Linux - Build.VM.wareVM"
end engineBuilderRun.Linux.VM.Path

private function engineBuilderRun.Linux.VM.RepoPath
   return "/host/Workspace/livecode/builds/livecode"
end engineBuilderRun.Linux.VM.RepoPath

private function engineBuilderRun.Linux.VM.CommercialPath
   return "/host/Workspace/livecode/builds/livecode-commercial"
end engineBuilderRun.Linux.VM.CommercialPath

private function engineBuilderRun.Windows.VM.CommercialPath
   return "C:/Workspace/livecode"
end engineBuilderRun.Windows.VM.CommercialPath

private function engineBuilderRun.Windows.VM.RepoPath
   return "C:/Workspace/livecode-commercial"
end engineBuilderRun.Windows.VM.RepoPath

private function engineBuilderRun.LogFolder
   return builderRepoFolder() & "/_build/logs"
end engineBuilderRun.LogFolder

private function engineBuilderRun.LogFolderLinux.VM
   return engineBuilderRun.Linux.VM.RepoPath() & "/_build/logs"
end engineBuilderRun.LogFolderLinux.VM

private function engineBuilderRun.LogFolderWindows.VM
   return engineBuilderRun.LinuxWimdowsRepoPath() & "/_build/logs"
end engineBuilderRun.LogFolderWindows.VM

---------------------------------------------------------------------

private command engineBuilderRun.BuildMac pEdition, pVersion
   builderLog "report", "Building Mac engines..."
   put empty into URL ("file:" & engineBuilderRun.LogFolder() & "/error_mac.log")
   put empty into URL ("file:" & engineBuilderRun.LogFolder() & "/build_mac.log")

   local tCommand
   put "sh" && q(builderCommercialFolder() & "/build-mac.osx") && ">" &&  q(engineBuilderRun.LogFolder() & "/build_mac.log") && "2>"  && q(engineBuilderRun.LogFolder() & "/error_mac.log") into tCommand
   get shell(tCommand)

   builderLog "message", "Mac build result..."
   builderLog "message", URL ("file:" & engineBuilderRun.LogFolder() & "/error_mac.log")
   builderLog "report", "Building Mac complete."
end engineBuilderRun.BuildMac

private command engineBuilderRun.BuildIOS pEdition, pVersion
   builderLog "report", "Building iOS engines..."
   put empty into URL ("file:" & engineBuilderRun.LogFolder() & "/error_ios.log")
   put empty into URL ("file:" & engineBuilderRun.LogFolder() & "/build_ios.log")

   local tCommand
   put "sh" && q(builderCommercialFolder() & "/build-ios.osx") && ">" &&  q(engineBuilderRun.LogFolder() & "/build_ios.log") && "2>"  && q(engineBuilderRun.LogFolder() & "/error_ios.log") into tCommand
   get shell(tCommand)

   builderLog "message", "iOS build result..."
   builderLog "message", URL ("file:" & engineBuilderRun.LogFolder() & "/error_ios.log")
   builderLog "report", "Building iOS complete."
end engineBuilderRun.BuildIOS

private command engineBuilderRun.BuildAndroid pEdition, pVersion
   builderLog "report", "Building Android engines..."
   put empty into URL ("file:" & engineBuilderRun.LogFolder() & "/error_android.log")
   put empty into URL ("file:" & engineBuilderRun.LogFolder() & "/build_android.log")

   local tCommand
   put "sh" && q(builderCommercialFolder() & "/build-android.osx") && ">" &&  q(engineBuilderRun.LogFolder() & "/build_android.log") && "2>"  && q(engineBuilderRun.LogFolder() & "/error_android.log") into tCommand
   get shell(tCommand)

   builderLog "message", "Android build result..."
   builderLog "message", URL ("file:" & engineBuilderRun.LogFolder() & "/error_android.log")
   builderLog "report", "Building Android complete."
end engineBuilderRun.BuildAndroid

private command engineBuilderRun.BuildLinux pEdition, pVersion
   local tCommand

   builderLog "report", "Building Linux engines..."
   put empty into URL ("file:" & engineBuilderRun.LogFolder() & "/error_linux.log")
   put empty into URL ("file:" & engineBuilderRun.LogFolder() & "/build_linux.log")

   builderLog "message", "Starting VM..."
   put q(engineBuilderRun..VM.RunPath()) && "-T fusion start" && q(engineBuilderRun.Linux.VM.Path()) && "nogui" into tCommand
   get shell(tCommand)
   if it contains "error" then
      builderLog "report", "Error starting .VM:" && it
      throw "failure"
   end if

   builderLog "message", "Compiling engines..."
   put q(engineBuilderRun.VM.RunPath()) && "-T fusion -gu build -gp runlog runScriptInGuest" && q(engineBuilderRun.Linux.VM.Path()) && "/bin/sh" && q(engineBuilderRun.Linux.VM.CommercialPath() & "/build-linux.lnx >" && engineBuilderRun.LogFolderLinux.VM() & "/build_linux.log" && "2>" && engineBuilderRun.LogFolderLinux.VM() & "/error_linux.log") into tCommand
   get shell(tCommand)
   if it contains "error" then
      builderLog "report", "Error building Linux engines:" && it
      throw "failure"
   end if
   builderLog "message", "Linux compile result..."
   builderLog "message", URL ("file:" & engineBuilderRun.LogFolder() & "/error_linux.log")

   builderLog "message", "Suspending VM..."
   put q(engineBuilderRun.VM.RunPath()) && "-T fusion suspend" && q(engineBuilderRun.Linux.VM.Path()) into tCommand
   get shell(tCommand)
   if it contains "error" then
      builderLog "report", "Error suspending .VM:" && it
      throw "failure"
   end if

   builderLog "report", "Building Linux complete."
end engineBuilderRun.BuildLinux

private command engineBuilderRun.BuildWindows pEdition, pVersion
   exit engineBuilderRun.BuildWindows

   builderLog "report", "Building Windows engines..."
   put empty into URL ("file:" & engineBuilderRun.LogFolder() & "/error_windows.log")

   local tCommand
   put q(engineBuilderRun.VM.RunPath()) && "-T fusion -gu administrator -gp runlog runScriptInGuest" && q(engineBuilderRun.Windows.VM.Path()) && q() && "cmd.exe /k \" & q(engineBuilderRun.Windows.VM.CommercialPath() & "/build-windows.bat" && pVersion && builderBuildsFolder()) into tCommand
   get shell(tCommand)

   if it is not empty then
      builderLog "report", "Error building Windows engines:" && it
      throw "failure"
   else
      builderLog "message", "Windows build result..."
      builderLog "message", URL ("file:" & engineBuilderRun.LogFolder() & "/error_windows.log")
      builderLog "report", "Building Windows complete."
   end if
end engineBuilderRun.BuildWindows

---------------------------------------------------------------------

private command engineBuilderRun.BuildEnvironment pEdition, pVersion
   builderLog "report", "Configuring commercial environment stack..."

   builderLog "message", "Fetching public key..."
   local tPostDataArray
   put pVersion into tPostDataArray["version"]
   put "jobbies123!" into tPostDataArray["password"]

   local tPostData
   repeat for each line tKey in the keys of tPostDataArray
      put "&" & tKey & "=" & urlencode(tPostDataArray[tKey]) after tPostData
   end repeat
   delete the first char of tPostData

   local tResult
   post tPostData to URL "http://livecode.com/livecode/building/fetch_key"
   put the result into tResult
   if the result is not empty then
      builderLog "report", "Error fetching public key for version" && pVersion & ":" && tResult
      throw "failure"
   end if

   local tPubKey
   put line 2 to -1 of it into tPubKey
   if line 1 of it is not "success" then
      builderLog "report", "Error fetching public key for version" && pVersion & ":" && line 2 to -1 of it
      throw "failure"
   end if

   builderLog "message", "New public key for version" && pVersion & "..."
   builderLog "message", tPubKey

   builderLog "message", "Writing public key to stack..."
   local tKeyFile
   put the tempName into tKeyFile
   put tPubKey into URL ("binfile:" & tKeyFile)
   get shell(builderSystemFolder() & "/public_key_setter -ui" && builderCommercialFolder() & "/src/environment.livecode" && tKeyFile)
   builderLog "message", it
   delete file tKeyFile

   builderLog "report", "Commercial environment stack configured."
end engineBuilderRun.BuildEnvironment

---------------------------------------------------------------------

command engineBuilderRun.Run pPlatform, pEdition, pVersion
   builderEnsureFolder engineBuilderRun.LogFolder()

   switch pPlatform
      case "environment"
         engineBuilderRun.BuildEnvironment pEdition, pVersion
         break
      case "mac"
         engineBuilderRun.BuildMac pEdition, pVersion
         break
      case "linux"
         engineBuilderRun.BuildLinux pEdition, pVersion
         break
      case "windows"
         engineBuilderRun.BuildWindows pEdition, pVersion
         break
      case "android"
         engineBuilderRun.BuildAndroid pEdition, pVersion
         break
      case "ios"
         engineBuilderRun.BuildiOS pEdition, pVersion
         break
   end switch
end engineBuilderRun.Run

---------------------------------------------------------------------
