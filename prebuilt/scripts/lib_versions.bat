REM # This file sets the libraries versions defined in versions/
REM Note: "SET /P" with a "<" redirect
REM sets the variable to the first line of the input file

FOR %%L in (OpenSSL ICU CEF CEFChromium Curl libz libzip libgif libjpeg libpng libfreetype libcairo) DO (
	SET PREBUILT_LIB=%%L
	SET /P !PREBUILT_LIB!_VERSION=<versions\!PREBUILT_LIB!
	IF EXIST "versions\!PREBUILT_LIB!_buildrevision" (
		SET /P !PREBUILT_LIB!_BUILDREVISION=<versions\!PREBUILT_LIB!_buildrevision
	)
	IF EXIST "versions\!PREBUILT_LIB!_buildversion" (
		SET /P !PREBUILT_LIB!_BUILDVERSION=<versions\!PREBUILT_LIB!_buildversion
	)
	IF EXIST "versions\!PREBUILT_LIB!_checksum" (
		SET /P !PREBUILT_LIB!_CHECKSUM=<versions\!PREBUILT_LIB!_checksum
	)
)

FOR /F "tokens=*" %%x IN ('git -C ../thirdparty/ log -n 1 "--format=%%H"') DO SET Thirdparty_VERSION=%%x
