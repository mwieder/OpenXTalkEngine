#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.22 currently ${libjpeg_VERSION} is 9b
#https://sourceforge.net/projects/libjpeg/files/latest/download
#https://ijg.org/files/jpegsrc.v9b.tar.gz

SHORT_THIS="jpeg"
THIS="libjpeg"
#URL_ROOT="https://sourceforge.net/projects/${THIS}/files/latest/download"
#URL_ROOT="https://ijg.org/files/${SHORT_THIS}sr${libjpeg_VERSION}.zip"
URL_ROOT="https://ijg.org/files/${SHORT_THIS}src.v${libjpeg_VERSION}.tar.gz"
# should do this with sed
JPEG_MAJOR_VERSION=$(echo "${libjpeg_VERSION}" | sed 's/[a-z]//')
ARCHIVE_DESTINATION="${SHORT_THIS}sr${JPEG_MAJOR_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

fetchBinary
rm -rf ${SHORT_THIS}-${libjpeg_VERSION}
#unxzBinary
untarBinary
mv ${SHORT_THIS}-${libjpeg_VERSION} ${ARCHIVE_DESTINATION}
# have to convert the windows-style line endings to linux
# sudo apt install dos2unix
pushd ${BUILDDIR}/${ARCHIVE_DESTINATION}
if [ -e "${BUILDDIR}/${ARCHIVE_DESTINATION}/configure" ] ; then
	dos2unix configure
	echo "running configure"
	./configure
fi
makeBinary
popd
buildLibrary
