@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM ############################################################################
REM #
REM #   BUILD CEF
REM #
REM Note that this assumes you have WSL enabled on the Windows computer
REM in order to run bash
REM alternatively, tar may be available on windows64 already (build 17063+)

REM 2023.07.18 currently ${CEF_BUILDVERSION} is 5672

rem SET CEF_BUILDVERSION=5672
SET CEF_ROOT="https://cef-builds.spotifycdn.com/cef_binary_"
SET CEF_URL=%CEF_ROOT%%CEF_VERSION%%2B%CEF_BUILDREVISION%%2Bchromium-%CEFChromium_VERSION%_
SET CEF_UNPACKED=%CEF_ROOT%%CEF_VERSION%+%CEF_BUILDREVISION%+chromium-%CEFChromium_VERSION%_

REM ECHO Build CEF-%CEF_VERSION%.%CEF_BUILDREVISION% for %BUILDTRIPLE%
ECHO Build CEF-%CEF_BUILDVERSION% for %BUILDTRIPLE%

IF %ARCH%==x86_64 (
	SET WIN_TYPE=windows64
) ELSE (
	SET WIN_TYPE=windows32
)
SET DOWNLOAD_URL=%CEF_URL%%WIN_TYPE%.tar.bz2
SET CEF_DST=..\build\CEF-%CEF_BUILDVERSION%_%WIN_TYPE%
SET CEF_UNPACKED_DIR=%CEF_UNPACKED%%WIN_TYPE%

REM CEF_TGZ names the .bz2 archive file
SET CEF_TGZ=%CEF_DST%.tar.bz2
REM SET CEF_SRC=%_ROOT_DIR%\%CEF_DST_NAME%
SET CEF_BIN=%_ROOT_DIR%\cef-%CEF_VERSION%.%CEF_BUILDREVISION%-%BUILDTRIPLE%-bin
SET CEF_BUILD_LOG=%_ROOT_DIR%\cef-%CEF_VERSION%.%CEF_BUILDREVISION%-%BUILDTRIPLE%.log

SET CEF_TAR=%_PACKAGE_DIR%\CEF-%CEF_VERSION%-%BUILDTRIPLE%-%CEF_BUILDREVISION%.tar

cd "%_ROOT_DIR%"

REM if there is no downloaded archive file
if not exist %CEF_TGZ% (
	echo Fetching CEF-%CEF_VERSION% for %BUILDTRIPLE%
	perl -MLWP::Simple -e "getstore('%DOWNLOAD_URL%', '%CEF_TGZ%')"
)

REM check for download success
if not exist %CEF_TGZ% (
	echo Failed to download %DOWNLOAD_URL% to %CEF_TGZ%
	EXIT /B 1
)

REM see if the archive file has been unpacked
if not exist %CEF_UNPACKED% (
	echo Unpacking CEF-%CEF_VERSION%.%CEF_BUILDREVISION% for %BUILDTRIPLE%
	bash -c "tar -jxf %CEF_DST_NAME%.tar.bz2"
)

ECHO Packaging CEF-%CEF_VERSION%.%CEF_BUILDREVISION% for %BUILDTRIPLE%
IF NOT EXIST "%CEF_BIN%\lib\CEF"     MKDIR "%CEF_BIN%\lib\CEF"
XCOPY /E /Y %CEF_UNPACKED%\Resources\*     "%CEF_BIN%\lib\CEF" >>%CEF_BUILD_LOG% 2>>&1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

IF %MODE%==debug (
	XCOPY /E /Y %CEF_UNPACKED%\Debug\*     "%CEF_BIN%\lib\CEF" >>%CEF_BUILD_LOG% 2>>&1
) ELSE (
	XCOPY /E /Y %CEF_UNPACKED%\Release\*     "%CEF_BIN%\lib\CEF" >>%CEF_BUILD_LOG% 2>>&1
)
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

REM Build the prebuilt CEF-%CEF_VERSION%.%CEF_BUILDREVISION% archives for %BUILDTRIPLE%

cd "%CEF_BIN%"
FOR /F "usebackq tokens=*" %%x IN (`cygpath.exe -u %CEF_TAR%`) DO SET CEF_TAR_CYG=%%x

rem ECHO Archiving CEF-%CEF_VERSION%.%CEF_BUILDREVISION% for %BUILDTRIPLE%
rem ECHO ========== ARCHIVING ==========  >>%CEF_BUILD_LOG%
bash -c "tar --create --file=%CEF_TAR_CYG% --transform='flags=r;s|^|%BUILDTRIPLE%/|' lib" >>%CEF_BUILD_LOG% 2>>&1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

rem ECHO Compressing CEF-%CEF_VERSION%.%CEF_BUILDREVISION% for %BUILDTRIPLE%
rem ECHO ========== COMPRESSING ==========  >>%CEF_BUILD_LOG%
bash -c "bzip2 --force %CEF_TAR_CYG%" >>%CEF_BUILD_LOG% 2>>&1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
