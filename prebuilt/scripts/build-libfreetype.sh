#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.09.07 currently ${libfreetype_VERSION} is 2.13.3
#https://sourceforge.net/projects/freetype/files/latest/download

THIS="libfreetype"
# should do this with sed
UNTARRED="freetype-${libfreetype_VERSION}"
URL_ROOT="https://sourceforge.net/projects/freetype/files/latest/download"
ARCHIVE_SOURCE="${THIS}-${libfreetype_VERSION}"
ARCHIVE_DESTINATION="${THIS}-${libfreetype_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"
INCLUDE_DIRECTORY="../../thirdparty/${THIS}/include"

function unxzBinary
{
	echo "Unzipping ${ARCHIVE_DESTINATION}.tar"
	unzip -o "${ARCHIVE_DESTINATION}.tar"
	# this creates ${UNTARRED}
	# delete any previous existing folder
	if [ -e "${ARCHIVE_DESTINATION}" ] ; then
		rm -rf ${ARCHIVE_DESTINATION}
	fi
	# rename the unzipped archive to ${ARCHIVE_DESTINATION}
	mv ${UNTARRED} ${ARCHIVE_DESTINATION}
}

function buildFTSrcLibrary {
	cmakeBinary
	mesonBinary
	cp -ur ${BUILDDIR}/${ARCHIVE_DESTINATION}/include ${INCLUDE_DIRECTORY}
	cp -ur ${BUILDDIR}/${ARCHIVE_DESTINATION}/src ${FILE_DIRECTORY}
}

fetchBinary
unxzBinary
buildFTSrcLibrary

