#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2023.10.27 currently ${CEF_BUILDVERSION} is 5993

CEF_ROOT="https://cef-builds.spotifycdn.com/cef_binary_"

# Grab the source for the library
CEF_URL="${CEF_ROOT}${CEF_VERSION}%2B${CEF_BUILDREVISION}%2Bchromium-${CEFChromium_VERSION}_${PLATFORM}"
CEF_UNPACKED="cef_binary_${CEF_VERSION}+${CEF_BUILDREVISION}+chromium-${CEFChromium_VERSION}_${PLATFORM}"
if [ "${ARCH}" == "x86" ] ; then
	# 32-bit builds were discontinued after version 101 (13 May 2022)
	CEF_SRC="https://cef-builds.spotifycdn.com/cef_binary_101.0.18%2Bg367b4a0%2Bchromium-101.0.4951.67_linux32.tar.bz2"
	CEF_DST="../build/CEF-${CEF_BUILDVERSION}_${PLATFORM}32"
	CEF_UNPACKED_DIR="${CEF_UNPACKED}32"
elif [ "${ARCH}" == "x86_64" ] ; then
	CEF_SRC="${CEF_URL}64.tar.bz2"
	CEF_DST="../build/CEF-${CEF_BUILDVERSION}_${PLATFORM}64"
	CEF_UNPACKED_DIR="${CEF_UNPACKED}64"
else 
  echo "No binaries available for arch"
fi

cd "${BUILDDIR}"

if [ ! -d "$CEF_DST" ] ; then
	CEF_TGZ="${CEF_DST}.tar.bz2"
	if [ ! -e "$CEF_TGZ" ] ; then
		echo "Fetching CEF source"
		fetchUrl "${CEF_SRC}" "${CEF_TGZ}"
		if [ $? != 0 ] ; then
			echo "downloading ${CEF_SRC} failed"
			if [ -e "${CEF_TGZ}" ] ; then 
				rm ${CEF_TGZ} 
			fi
			exit
		fi
	fi

	if [ ! -d "${CEF_UNPACKED_DIR}/Debug" ] ; then
		echo "Unpacking CEF source"
		tar -vjxf "${CEF_TGZ}"
	fi
fi
				
# just repackage existing prebuilts and strip unneeded symbols
function buildCEF {
	local PLATFORM=$1
	local ARCH=$2
	
	CEF_LIB_DIR="${OUTPUT_DIR}/lib/${PLATFORM}/${ARCH}/CEF"
	mkdir -p "${CEF_LIB_DIR}"
	cp -a "${CEF_UNPACKED_DIR}/Release/"* "${CEF_LIB_DIR}"
	cp -a "${CEF_UNPACKED_DIR}/Resources/"* "${CEF_LIB_DIR}"
	rm -r "../../thirdparty/libcef/include/*"
	rm -r "../../thirdparty/libcef/libcef_dll/*"
	cp -al "${CEF_UNPACKED_DIR}/include" "../../thirdparty/libcef"
	cp -al "${CEF_UNPACKED_DIR}/libcef_dll" "../../thirdparty/libcef"
#	cp -av "${CEF_UNPACKED_DIR}/*.txt" "../../thirdparty/libcef"
	strip --strip-unneeded "${CEF_LIB_DIR}/libcef.so"
}

#echo "building from ${BUILDDIR}/${CEF_DST}" 
buildCEF "${PLATFORM}" "${ARCH}"

