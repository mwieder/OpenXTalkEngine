#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.22 currently ${libfreetype_VERSION} is 2.13.2
#https://sourceforge.net/projects/freetype/files/latest/download

THIS="libfreetype"
# the version downloaded is 2.13.2 but in the tar file is 2.13.3
ACTUAL_VERSION="2.14.3"
# should do this with sed
UNTARRED="freetype-${ACTUAL_VERSION}"
URL_ROOT="https://sourceforge.net/projects/freetype/files/latest/download"
ARCHIVE_DESTINATION="${THIS}-${libfreetype_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"
INCLUDE_DIRECTORY="../../thirdparty/${THIS}/include"

function unxzBinary
{
	echo "Unzipping ${ARCHIVE_DESTINATION}.tar"
	unzip -o "${ARCHIVE_DESTINATION}.tar"
	if [ -e "${ARCHIVE_DESTINATION}" ] ; then
		rm -rf ${ARCHIVE_DESTINATION}
	fi
	mv ${UNTARRED} ${ARCHIVE_DESTINATION}
}

function buildFTSrcLibrary {
	cmakeBinary
	mesonBinary
	# MDW 2025.03.28 use rsync instead of cp because osx doesn't support "cp -u"
	rsync -ur ${BUILDDIR}/${ARCHIVE_DESTINATION}/include ${INCLUDE_DIRECTORY}
	rsync -ur ${BUILDDIR}/${ARCHIVE_DESTINATION}/src ${FILE_DIRECTORY}
}

fetchBinary
unxzBinary
buildFTSrcLibrary
