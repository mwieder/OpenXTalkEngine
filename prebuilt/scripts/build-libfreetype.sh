#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2025.09.19 currently ${libfreetype_VERSION} is 2.14.1
#https://sourceforge.net/projects/freetype/files/latest/download

THIS="libfreetype"
# the version downloaded is 2.14.0 but in the tar file is 2.14.1
ACTUAL_VERSION=${libfreetype_VERSION}
UNTARRED="freetype-${ACTUAL_VERSION}"
URL_ROOT="https://sourceforge.net/projects/freetype/files/latest/download"
ARCHIVE_DESTINATION="${THIS}-${libfreetype_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"
INCLUDE_DIRECTORY="../../thirdparty/${THIS}/include"

# strip the minor version, i.e. 2.14.1 -> 2.14
VERSION_MAJOR=$(echo "${ARCHIVE_DESTINATION}" | sed -e 's/\.[^\.]$//')
#ARCHIVE_DESTINATION="${VERSION_MAJOR}"

function unxzBinary
{
	echo "Unzipping ${ARCHIVE_DESTINATION}.tar"
	unzip -o "${ARCHIVE_DESTINATION}.tar"
	if [ -e "${ARCHIVE_DESTINATION}" ] ; then
		rm -rf ${ARCHIVE_DESTINATION}
	fi
	mv "${UNTARRED}" "${VERSION_MAJOR}"
	ARCHIVE_DESTINATION=${VERSION_MAJOR}
}

function buildFTSrcLibrary {
	cmakeBinary
	mesonBinary
	# MDW 2025.03.28 use rsync instead of cp because osx doesn't support "cp -u"
	rsync -ur ${BUILDDIR}/${ARCHIVE_DESTINATION}/include ${INCLUDE_DIRECTORY}
	rsync -ur ${BUILDDIR}/${ARCHIVE_DESTINATION}/src ${FILE_DIRECTORY}
}

fetchBinary
#ARCHIVE_DESTINATION="${VERSION_MAJOR}"
unxzBinary
buildFTSrcLibrary
