#!/bin/bash

# Abort building if any errors occur
set -e

# Build location
export BASEDIR=$(dirname $0)
export BUILDDIR="`pwd`/build"
export INSTALL_DIR="`pwd`/build/install"
export OUTPUT_DIR="`pwd`"
mkdir -p "${BUILDDIR}"
mkdir -p "${INSTALL_DIR}"
mkdir -p "${OUTPUT_DIR}"

# Target platform and architecture
export PLATFORM=$1
export ARCH=$2

#only ios and android subplatforms are used
# MDW 2025.03.27 Emscripten: allow JS and WASM?
if [ "${PLATFORM}" == "ios" ] || [ "${PLATFORM}" == "android" ] ; then
	export SUBPLATFORM=$3
# MDW 2025.03.27 Emscripten: allow JS and WASM?
elif [ "${PLATFORM}" == "emscripten" ] ; then
	export SUBPLATFORM=
else
	export SUBPLATFORM=
fi

# Capture the existing build variables, if any
export CUSTOM_CC="${CC}"
export CUSTOM_CXX="${CXX}"
export CUSTOM_EMMAKE="${EMMAKE}"
export CUSTOM_EMCONFIGURE="${EMCONFIGURE}"

echo "PLATFORM=" ${PLATFORM}

# Set which libs to build for the target platform
case "${PLATFORM}" in
	android)
		PREBUILT_LIBS="openssl icu libz libzip libgif libjpeg libpng libfreetype libiodbc"
		;;
	mac)
		PREBUILT_LIBS="openssl icu libz libzip libgif libjpeg libpng libfreetype libiodbc"
		;;
	ios)
		PREBUILT_LIBS="openssl icu libz libzip libgif libjpeg libpng libfreetype libiodbc"
		;;
	win32)
		PREBUILT_LIBS="openssl curl icu cef libz libzip libgif libjpeg libpng libfreetype libiodbc"
		;;
	linux)
		PREBUILT_LIBS="openssl curl icu cef libz libzip libgif libjpeg libpng libfreetype libiodbc"
		;;
	emscripten)
		PREBUILT_LIBS="icu libz libzip libgif libjpeg libpng libfreetype libiodbc"
		;;
esac

echo "PREBUILT_LIBS=" ${PREBUILT_LIBS}
echo "BASEDIR=" ${BASEDIR}

# Build all of the libraries that the target platform depends on
for t_lib in ${PREBUILT_LIBS} ; do
	echo "Building ${t_lib} using ${BASEDIR}/scripts/build-${t_lib}.sh"
	${BASEDIR}/scripts/build-${t_lib}.sh
done
